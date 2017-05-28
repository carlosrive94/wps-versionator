import requests
import json
from urllib.request import urlopen
from bs4 import BeautifulSoup

# API KEY for Google Custom Search API
apikey = 'AIzaSyClCn_nNkXcxnsdpXxTCG_LwVff66W4D7g'

# CSE cx identifier
cx = '016149970605689745710:lzye9oapw7y'

# Query to execute
query = '%E2%80%9Cindex+of%E2%80%9D+inurl%3Awp-content+site%3A'

# Sites we'll search
sites = ['es', 'ad', 'at', 'be', 'ch', 'cy', 'cz', 'de', 'dk', 'fl', 'fr', 'gr', 'ht', 'hu', 'ie', 'is', 'it', 'lu',
         'ma', 'mc', 'nl', 'no', 'pt', 'se', 'uk']


# Returns the wordpress version of the domain provided if the default /readme.html is still available.
# If not, returns -1 instead
def get_version(domain):
    readme = 'http://' + domain + '/readme.html'

    try:
        # Open the requested url
        f = urlopen(readme)
        # Parse the html w/ BeautifulSoup
        soup = BeautifulSoup(f.read(), 'html.parser')
        # Get Wp version trough the default logo
        version = soup.find('h1', {'id': 'logo'}).text.split(' ')[2].rstrip()

    except Exception as e:
        # If content not available return -1
        print('Error on getting version of ' + domain + ':', e)
        version = '-1'

    return version


data = {'urls': {}}

# Execute the query for every site listed on sites list
for site in sites:
    url = 'https://www.googleapis.com/customsearch/v1?key=' + apikey + '&cx=' + cx + '&q=' + query + site
    urls_site = []

    # Goes through all the available pages of the CSE
    index = 1
    while index != -1:
        req_url = url + '&start=' + str(index)
        print('Request to: ' + req_url)
        try:
            resp = requests.get(req_url).json()

            # For every item on the result get the domain & its wordpress version
            for item in resp['items']:
                domain = item['displayLink']
                version = get_version(domain)
                print('Adding ' + domain + ' / ' + version)
                urls_site.append({'url': domain, 'version': version})
        except:
            pass

        # Tries to access nextPage, if not available stop the loop and proceed with next site
        try:
            index = resp['queries']['nextPage'][0]['startIndex']
        except:
            index = -1

    # Don't store site info if it's empty
    if urls_site:
        data['urls'][site] = urls_site

# Store results on json file
with open("..\data\data.json", "w") as outfile:
    json.dump(data, outfile, indent=4)
    print('Data stored on data.json')
