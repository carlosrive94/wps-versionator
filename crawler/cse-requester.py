import requests
import json
from urllib.request import urlopen
from bs4 import BeautifulSoup

apikey = 'AIzaSyClCn_nNkXcxnsdpXxTCG_LwVff66W4D7g'
cx = '016149970605689745710:lzye9oapw7y'
query = '%E2%80%9Cindex+of%E2%80%9D+inurl:wp-content'
number_of_pages = 8


def get_version(domain):
    readme = 'http://' + domain + '/readme.html'
    try:
        f = urlopen(readme)
        soup = BeautifulSoup(f.read(), 'html.parser')
        version = soup.find('h1', {'id': 'logo'}).text.split(' ')[2].rstrip()
    except Exception as e:
        print(e)
        version = '-1'
    return version


data = []

for i in range(number_of_pages):
    req_url = 'https://www.googleapis.com/customsearch/v1?key=' + apikey + '&cx=' + cx + '&q=' + query + '&start=' + str(
        (i * 10) + 1)
    resp = requests.get(req_url).json()
    for item in resp['items']:
        domain = item['displayLink']
        version = get_version(domain)
        data.append({'url': domain, 'version': version})

with open("..\data\data.json", "w") as outfile:
    json.dump({'urls': data}, outfile, indent=4)
