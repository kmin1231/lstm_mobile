# app.py

from flask import Flask, jsonify
from data_fetch import fetch_stock_data

app = Flask(__name__)


@app.route('/')
def home():
    return "Hello, Flask!"

@app.route('/stock/<stock_code>', methods=['GET'])
def get_stock_price(stock_code):
    stock_price = fetch_stock_data(stock_code)
    return jsonify(stock_price)

if __name__ == '__main__':
    app.run(port=5000, debug=True)  # Flask 서버를 5000번 포트에서 실행
