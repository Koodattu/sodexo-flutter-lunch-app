import requests
from bs4 import BeautifulSoup
import json

# Funktio tietojen keräämiseksi yksittäisestä ravintolasivusta
def get_restaurant_details(link, restaurant_type, location):
    url = "https://www.sodexo.fi/" + link['href']
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    
    name = link.text
    hours = soup.find_all('span', class_='hours')
    open_hours = hours[0].text.strip() if len(hours) > 0 else 'N/A'
    lunch_hours = hours[1].text.strip() if len(hours) > 1 else 'N/A'
    
    if open_hours == 'N/A' or lunch_hours == 'N/A':
        office_hours = soup.find_all('div', class_='office-hours__item-slots')
        if len(office_hours) > 0:
            open_hours = office_hours[0].text.strip() if open_hours == 'N/A' else open_hours
            lunch_hours = office_hours[1].text.strip() if len(office_hours) > 1 and lunch_hours == 'N/A' else lunch_hours
    
    url_id = url.split('/')[-1]
    json_url = soup.find('a', href=lambda x: x and '/weekly_json/' in x)
    json_id = json_url['href'].split('/')[-1] if json_url else None

    return {
        'json_id': json_id,
        'url_id': url_id,
        'name': name,
        'location': location,
        'lunch_hours': lunch_hours,
        'open_hours': open_hours,
        'type': restaurant_type
    }

# Funktio kaikkien ravintoloiden linkkien scrapaamiseen ja tietojen keräämiseen
def scrape_restaurants(base_url, restaurant_type):
    response = requests.get(base_url)
    soup = BeautifulSoup(response.text, 'html.parser')
    
    restaurant_links = soup.find_all('a', href=lambda x: x and '/ravintolat/' in x)
    
    restaurants = []
    for link in restaurant_links:
        print("Scraping", link.text)
        location = link.find_previous('h3').text
        restaurant_details = get_restaurant_details(link, restaurant_type, location)
        restaurants.append(restaurant_details)
    
    return restaurants

# URLit eri ravintolatyyppien scrapaamiseen
lunch_restaurants_url = "https://www.sodexo.fi/lounasravintolat"
student_restaurants_url = "https://www.sodexo.fi/opiskelijaravintolat"
cafes_url = "https://www.sodexo.fi/kahvilat"

# Scrapaa lounasravintolat
lunch_restaurants = scrape_restaurants(lunch_restaurants_url, 'lunch')

# Scrapaa opiskelijaravintolat
student_restaurants = scrape_restaurants(student_restaurants_url, 'student')

# Scrapaa kahvilat
cafes = scrape_restaurants(cafes_url, 'cafe')

# Yhdistä kaikki ravintolat yhteen listaan
all_restaurants = lunch_restaurants + student_restaurants + cafes

# Tallenna kaikki ravintolat JSON-tiedostoksi
with open('sodexo_restaurants.json', 'w', encoding='utf-8') as json_file:
    json.dump(all_restaurants, json_file, ensure_ascii=False, indent=4)

print("Data tallennettu tiedostoon sodexo_restaurants.json")
