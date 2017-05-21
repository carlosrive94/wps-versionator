import requests
import json
from urllib.request import urlopen
from bs4 import BeautifulSoup

apikey = 'AIzaSyClCn_nNkXcxnsdpXxTCG_LwVff66W4D7g'
cx = '016149970605689745710:lzye9oapw7y'
query = '%E2%80%9Cindex+of%E2%80%9D+inurl%3Awp-content'
number_of_pages = 8
start_page = 1


def get_version(domain):
    readme = 'http://' + domain + '/readme.html'
    try:
        f = urlopen(readme)
        soup = BeautifulSoup(f.read(), 'html.parser')
        version = soup.find('h1', {'id': 'logo'}).text.split(' ')[2].rstrip()
    except Exception as e:
        print('Error on getting version of ' + domain + ':', e)
        version = '-1'
    return version


data = []

for i in range(number_of_pages):
    start = ((i + start_page) * 10) + 1
    req_url = 'https://www.googleapis.com/customsearch/v1?key=' + apikey + '&cx=' + cx + '&q=' + query + '&start=' + str(
        start)
    try:
        print('Request to: ' + req_url)
        resp = requests.get(req_url).json()
        print(resp)

        for item in resp['items']:
            domain = item['displayLink']
            version = get_version(domain)
            print('Adding ' + domain + ' / ' + version)
            data.append({'url': domain, 'version': version})

    except Exception as e:
        print('Error accesing page ' + str(start) + ':', e)

with open("..\data\data.json") as outfile:
    data += json.load(outfile)['urls']

with open("..\data\data.json", "w") as outfile:
    json.dump({'urls': data}, outfile, indent=4)
    print('Data loaded on data.json')
