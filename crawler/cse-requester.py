import requests
import json
from urllib.request import urlopen
from bs4 import BeautifulSoup

apikey = 'AIzaSyClCn_nNkXcxnsdpXxTCG_LwVff66W4D7g'
cx = '016149970605689745710:lzye9oapw7y'
query = '%E2%80%9Cindex+of%E2%80%9D+inurl%3Awp-content+site%3A'
sites = ['es', 'ad', 'at', 'be', 'ch', 'cy', 'cz']


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


data = {'urls': {}}

for site in sites:
    url = 'https://www.googleapis.com/customsearch/v1?key=' + apikey + '&cx=' + cx + '&q=' + query + site
    data['urls'][site] = []

    index = 1
    while index != -1:
        req_url = url + '&start=' + str(index)
        print('Request to: ' + req_url)
        try:
            resp = requests.get(req_url).json()
            for item in resp['items']:
                domain = item['displayLink']
                version = get_version(domain)
                print('Adding ' + domain + ' / ' + version)
                data['urls'][site].append({'url': domain, 'version': version})
        except:
            pass

        try:
            index = resp['queries']['nextPage'][0]['startIndex']
        except:
            index = -1

with open("..\data\data.json", "w") as outfile:
    json.dump(data, outfile, indent=4)
    print('Data loaded on data.json')
