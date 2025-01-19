import requests
from bs4 import BeautifulSoup
import json
import os
import time
from dotenv import load_dotenv

load_dotenv()
api_key = os.getenv('GEOCODING_API_KEY')

# Function to get restaurant details
def get_restaurant_details(link, restaurant_type, location, lat, lon):
    url = "https://www.sodexo.fi/" + link['href']
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    
    name = link.text
    hours = soup.find_all('span', class_='hours')
    open_hours = hours[0].text.strip() if len(hours) > 0 else None
    lunch_hours = hours[1].text.strip() if len(hours) > 1 else None
    
    if open_hours == None or lunch_hours == None:
        office_hours = soup.find_all('div', class_='office-hours__item-slots')
        if len(office_hours) > 0:
            open_hours = office_hours[0].text.strip() if open_hours == None else open_hours
            lunch_hours = office_hours[1].text.strip() if len(office_hours) > 1 and lunch_hours == None else lunch_hours
    
    url_id = url.split('/')[-1]
    json_url = soup.find('a', href=lambda x: x and '/weekly_json/' in x)
    json_id = json_url['href'].split('/')[-1] if json_url else None

    return {
        'json_id': json_id,
        'url_id': url_id,
        'name': name,
        'location': location,
        'lat': lat,
        'lon': lon,
        'open_hours': open_hours,
        'lunch_hours': lunch_hours,
        'type': [restaurant_type]
    }

# Dictionary to store already fetched coordinates
coordinates_cache = {}

def get_lat_lon(address):
    if address in coordinates_cache:
        return coordinates_cache[address]
    
    time.sleep(1)
    url = f"https://geocode.maps.co/search?q={address}&api_key={api_key}"
    response = requests.get(url)
    
    if response.status_code == 200:
        data = response.json()
        if len(data) > 0:
            lat = data[0].get('lat')
            lon = data[0].get('lon')
            return lat, lon
        else:
            return None, None
    else:
        return None, None

# Function to scrape restaurant data
def scrape_restaurants(base_url, restaurant_type, all_restaurants):
    response = requests.get(base_url)
    soup = BeautifulSoup(response.text, 'html.parser')
    
    restaurant_links = soup.find_all('a', href=lambda x: x and '/ravintolat/' in x)
    
    for link in restaurant_links:
        print("Scraping", link.text)
        location = link.find_previous('h3').text
        lat, lon = get_lat_lon(location)
        restaurant_details = get_restaurant_details(link, restaurant_type, location, lat, lon)

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
