# data_fetch.py
from flask import Flask, jsonify
from kis import fetch_stock_price  

app = Flask(__name__)

@app.route('/stock/<string:stock_code>', methods=['GET'])
def get_stock_price(stock_code):
    stock_data = fetch_stock_price(stock_code)
    if stock_data:
        return jsonify(stock_data), 200
    else:
        return jsonify({'error': 'Unable to fetch stock price'}), 500

if __name__ == '__main__':
    app.run(debug=True)