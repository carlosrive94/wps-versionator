import re
import json
from bs4 import BeautifulSoup
from scrapy.spiders import Spider
from scrapy.selector import Selector
from urllib.request import urlopen
from urllib.parse import urlparse


class WPSpider(Spider):
    name = 'wpspider'
    allowed_domains = ['www.google.com']
    start_urls = ['https://www.google.es/search?q=%E2%80%9Cindex+of%E2%80%9D+inurl:wp-content&start=' + str(i * 10) for
                  i in range(20)]

    def parse(self, response):
        sel = Selector(response)
        urls = sel.xpath('//h3/a/@href').extract()
        urls = [re.search('q=(.*)&sa', n).group(1) for n in urls]

        data = []
        for url in urls:
            parsed_uri = urlparse(url)
            domain = '{uri.scheme}://{uri.netloc}/'.format(uri=parsed_uri)
            version = get_version(domain)
            print('****Domain:' + domain)
            data.append({'url': domain, 'version': version})

        with open("..\data\data.json", "w") as outfile:
            json.dump({'urls': data}, outfile, indent=4)


def get_version(domain):
    readme = domain + 'readme.html'
    try:
        f = urlopen(readme)
        soup = BeautifulSoup(f.read(), 'html.parser')
        version = soup.find('h1', {'id': 'logo'}).text.split(' ')[2].rstrip()
    except:
        version = '-1'
    return version
