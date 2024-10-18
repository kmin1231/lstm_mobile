# kis_token.py

import configparser # module to read configuration files
import requests     # module to make HTTP requests in Python
import os

config = configparser.ConfigParser()    # 'ConfigParser' instance
config_file_path = os.path.join(os.path.dirname(__file__), 'kis.key')
config.read(config_file_path)
# config.read('kis.key')  # reads 'kis.key' file

# retrieves 'appkey', 'appsecret', 'accountNo' from 'KIS' section
appkey = config.get('KIS', 'appkey')
appsecret = config.get('KIS', 'appsecret')
accountNo = config.get('KIS', 'accountNo')

# function to request access token
def get_access_token():
    # URL endpoint
    url = 'https://openapi.koreainvestment.com:9443/oauth2/tokenP'
    
    # Request Payload - 'POST' method
    payload = {
        'grant_type': 'client_credentials',
        'appkey': appkey,
        'appsecret': appsecret
    }

    # HTTP headers
    headers = {
        # request to get data in JSON format
        'Content-Type': 'application/json; charset=UTF-8'
    }

    response = requests.post(url, json=payload, headers=headers)
    
    if (response.status_code == 200):   # 200 OK
        access_token = response.json().get('access_token')

        # writes 'access_token" in text file
        with open('access_token.txt', 'w') as f:
            f.write(access_token)
        return access_token
    
    else:   # request failed
        error_response = response.json()  # dictionary format
        error_code = error_response.get('error_code')
        error_description = error_response.get('error_description')

        print(f"Error Code: {error_code}")
        print(f"Error Description: {error_description}")
        return None

# [KIS Developers - API Documentation]
# https://apiportal.koreainvestment.com/apiservice/oauth2#L_5c87ba63-740a-4166-93ac-803510bb9c02



if __name__ == "__main__":
    # calls 'get_access_token()' function to obtain the access token
    access_token = get_access_token()
    
    if (access_token):
        print('Access token is successfuly issued!')
        # not prints 'access token' to protect authentication information
        # print('Access Token:', access_token)
    # else:
        # print('Error: Failed to obtain access token.')
        # pass