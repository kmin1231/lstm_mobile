# kis.py

# from kis_token import get_access_token  # imports from 'kis_token.py'
from fin_api.stock_data import stock_codes      # imports from 'stock_data.py'

import os
from datetime import datetime
import configparser # module to read configuration files
import requests     # module to make HTTP requests in Python
import mojito       # module to interact with KIS API
import pprint       # Python built-in module 'Pretty Print' 

# [KIS - 'mojito'] https://pypi.org/project/mojito2
# pip install mojito2

config = configparser.ConfigParser()
config_file_path = os.path.join(os.path.dirname(__file__), 'kis.key')
config.read(config_file_path)

# extracts information from configuration file 'kis.key'
appkey = config.get('KIS', 'appkey')
appsecret = config.get('KIS', 'appsecret')
accountNo = config.get('KIS', 'accountNo')

# creates a 'mojito.KoreaInvestment' instance
broker = mojito.KoreaInvestment(api_key=appkey, api_secret=appsecret, acc_no=accountNo)

# function to retrieve stock information for a given 'stock_code'
def fetch_stock_price(stock_code):
    try:
        # requests all the information related to the specified stock
        response = broker.fetch_price(stock_code)
        return response
    
    except Exception as e:
        print(f"Error fetching price for {stock_code}: {str(e)}")
        return None
    
# function to print the stock price information for a given 'stock_code'
def print_stock_price(stock_code):
    stock_data = fetch_stock_price(stock_code)
    stock_name = stock_codes.get(stock_code)
    
    if (stock_data) and ('output' in stock_data):
        # 'stck_prpr': current price
        current_price = stock_data['output'].get('stck_prpr')

        # formatted price
        f_price = f"{int(current_price): ,}"

        index = list(stock_codes.keys()).index(stock_code) + 1
        
        if (current_price):
            print(f"{index:02d}. {stock_name} ({stock_code}): {f_price}")
        else:
            print(f"Error: cannot retrieve price information for {stock_code}.")
    else:
        print(f"Error: cannot retrieve price information for {stock_code}.")
    
# function to print the stock information for 'stock_codes'
def print_all_stock_prices(stock_codes):
    for code in stock_codes:
        print_stock_price(code)



if __name__ == "__main__":
    # dictionary of stock codes & names
    current_time = datetime.now().strftime("%Y-%m%d %H:%M:%S")

    print(f"\n>> Current Stock Price ({current_time})")
    print_all_stock_prices(stock_codes)

    # test for 'output'
    # test = fetch_stock_price("005930")
    # pprint.pprint(test)