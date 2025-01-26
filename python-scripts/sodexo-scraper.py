import requests
from bs4 import BeautifulSoup
import json
import os
import time
from dotenv import load_dotenv

load_dotenv()
api_key = os.getenv('GEOCODING_API_KEY')

# Dictionary to store already fetched coordinates
coordinates_cache = {}

def get_lat_lon(address):
    """
    Fetches latitude and longitude for a given address using the geocoding API.
    Caches results to minimize API calls.
    """
    if address in coordinates_cache:
        return coordinates_cache[address]

    # Respect rate limits by sleeping between requests
    time.sleep(1)
    url = f"https://geocode.maps.co/search?q={address}&api_key={api_key}"
    response = requests.get(url)

    if response.status_code == 200:
        data = response.json()
        if len(data) > 0:
            lat = data[0].get('lat')
            lon = data[0].get('lon')
            coordinates_cache[address] = (lat, lon)
            return lat, lon
        else:
            print(f"No geocoding results for address: {address}")
            return None, None
    else:
        print(f"Geocoding API request failed for address: {address} with status code {response.status_code}")
        return None, None

# Function to get restaurant details
def get_restaurant_details(link, restaurant_type):
    """
    Extracts detailed information about a restaurant from its webpage.
    Constructs the full address and formats the location field.
    """
    url = "https://www.sodexo.fi/" + link['href']
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')

    name = link.text.strip()

    # Extract operating hours
    hours = soup.find_all('span', class_='hours')
    open_hours = hours[0].text.strip() if len(hours) > 0 else None
    lunch_hours = hours[1].text.strip() if len(hours) > 1 else None

    if open_hours is None or lunch_hours is None:
        office_hours = soup.find_all('div', class_='office-hours__item-slots')
        if len(office_hours) > 0:
            open_hours = office_hours[0].text.strip() if open_hours is None else open_hours
            lunch_hours = office_hours[1].text.strip() if len(office_hours) > 1 and lunch_hours is None else lunch_hours

    url_id = url.split('/')[-1]
    json_url = soup.find('a', href=lambda x: x and '/weekly_json/' in x)
    json_id = json_url['href'].split('/')[-1] if json_url else None

    # Extract and format address
    address_div = soup.find('div', class_='address')
    street = None
    postal_code = None
    city = None

    if address_div:
        street_div = address_div.find('div', class_='field--name-field-street-address')
        postal_code_div = address_div.find('div', class_='field--name-field-postal-code')
        postal_office_div = address_div.find('div', class_='field--name-field-postal-office')

        street = street_div.text.strip() if street_div else None
        postal_code = postal_code_div.text.strip() if postal_code_div else None
        city = postal_office_div.text.strip() if postal_office_div else None

    # If city is not found in the address, it will be provided externally
    return {
        'json_id': json_id,
        'url_id': url_id,
        'name': name,
        'street': street,
        'postal_code': postal_code,
        'city': city,
        'open_hours': open_hours,
        'lunch_hours': lunch_hours,
        'type': [restaurant_type]
    }

# Function to scrape restaurant data
def scrape_restaurants(base_url, restaurant_type, all_restaurants):
    """
    Scrapes restaurant links from the base URL and extracts their details.
    Fetches coordinates based on the full address.
    """
    response = requests.get(base_url)
    soup = BeautifulSoup(response.text, 'html.parser')

    restaurant_links = soup.find_all('a', href=lambda x: x and '/ravintolat/' in x)

    for link in restaurant_links:
        restaurant_name = link.text.strip()
        print(f"Scraping {restaurant_name}")

        # Extract location (city) from the previous h3 tag
        location_tag = link.find_previous('h3')
        external_city = location_tag.text.strip() if location_tag else None

        # Get detailed restaurant info
        restaurant_details = get_restaurant_details(link, restaurant_type)

        # Determine the city to use
        city = restaurant_details['city'] if restaurant_details['city'] else external_city

        # Construct the full address
        address_parts = []
        if restaurant_details['street']:
            address_parts.append(restaurant_details['street'])
        if restaurant_details['postal_code']:
            address_parts.append(restaurant_details['postal_code'])
        if city:
            address_parts.append(city)

        if len(address_parts) > 1:
            # If both street and postal code are present
            if restaurant_details['street'] and restaurant_details['postal_code']:
                full_address = f"{restaurant_details['street']}, {restaurant_details['postal_code']} {city}"
            # If either street or postal code is missing
            elif restaurant_details['street']:
                full_address = f"{restaurant_details['street']} {city}"
            elif restaurant_details['postal_code']:
                full_address = f"{restaurant_details['postal_code']} {city}"
            else:
                full_address = city
        elif len(address_parts) == 1:
            full_address = address_parts[0]
        else:
            full_address = None

        # If full_address is not available, fall back to city
        if not full_address and city:
            full_address = city

        # Fetch coordinates based on the full address
        if full_address:
            lat, lon = get_lat_lon(full_address)
        else:
            lat, lon = None, None

        # Update location field
        if full_address:
            restaurant_details['location'] = full_address
        else:
            restaurant_details['location'] = external_city if external_city else "Unknown Location"

        # Assign coordinates
        restaurant_details['lat'] = lat
        restaurant_details['lon'] = lon

        # Remove intermediate address fields
        del restaurant_details['street']
        del restaurant_details['postal_code']
        del restaurant_details['city']

        # Check if the restaurant already exists
        existing_restaurant = next((r for r in all_restaurants if r['url_id'] == restaurant_details['url_id']), None)

        if existing_restaurant:
            # Update existing fields if new data is not None or changed
            for key, value in restaurant_details.items():
                if key == "type":
                    # Ensure the type is updated without overwriting
                    for t in restaurant_details['type']:
                        if t not in existing_restaurant['type']:
                            existing_restaurant['type'].append(t)
                elif value is not None and value != existing_restaurant.get(key):
                    existing_restaurant[key] = value
        else:
            all_restaurants.append(restaurant_details)

# Load existing data
if os.path.exists('sodexo_restaurants.json'):
    with open('sodexo_restaurants.json', 'r', encoding='utf-8') as json_file:
        all_restaurants = json.load(json_file)
else:
    all_restaurants = []

# Scraping URLs
lunch_restaurants_url = "https://www.sodexo.fi/lounasravintolat"
student_restaurants_url = "https://www.sodexo.fi/opiskelijaravintolat"
cafes_url = "https://www.sodexo.fi/kahvilat"

# Scrape and update restaurants
scrape_restaurants(lunch_restaurants_url, 'lunch', all_restaurants)
scrape_restaurants(student_restaurants_url, 'student', all_restaurants)
scrape_restaurants(cafes_url, 'cafe', all_restaurants)

# Save updated data
with open('sodexo_restaurants.json', 'w', encoding='utf-8') as json_file:
    json.dump(all_restaurants, json_file, ensure_ascii=False, indent=4)

print("Data saved to sodexo_restaurants.json")
