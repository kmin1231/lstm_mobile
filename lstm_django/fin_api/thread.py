# thread.py

from stock_data import stock_codes
from kis import fetch_stock_price, print_stock_price

import concurrent.futures   # Python standard library

# function to print real-time stock prices for each stock concurrently!  
def print_prices_cncr(stock_codes):
    
    # creates multiple threads
    with concurrent.futures.ThreadPoolExecutor() as executor:
        executor.map(print_stock_price, stock_codes)



if __name__ == "__main__":
    print_prices_cncr(stock_codes.keys())