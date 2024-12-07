import numpy as np
import pandas as pd
import FinanceDataReader as fdr
from sklearn.preprocessing import MinMaxScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense
from datetime import date
import matplotlib.pyplot as plt
import os, platform, time
import sqlite3
from tqdm import tqdm
from concurrent.futures import ThreadPoolExecutor, ProcessPoolExecutor
import threading
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# import matplotlib
# matplotlib.use('Agg')


tickers = ['005930', '000660', '373220', '207940', '005380',
           '005935', '068270', '000270', '105560', '005490']


start_date = '2020-01-01'
# start_date = '2023-01-01'
end_date = date.today().strftime('%Y-%m-%d')

time_steps = 20
epochs = 100
batch_size = 8


# if platform.system() == 'Windows':
#     SAVE_DIRECTORY = "C:/Users/min/Desktop"
# else:
#     SAVE_DIRECTORY = os.path.expanduser("~/lstm_results")

# if not os.path.exists(SAVE_DIRECTORY):
#     os.makedirs(SAVE_DIRECTORY)


def prepare_data(ticker, start_date, end_date):
    df = fdr.DataReader(ticker, start=start_date, end=end_date)
    df = df.reset_index()
    data = df[['Date', 'Close']].copy()
    data['Date'] = pd.to_datetime(data['Date'])
    
    scaler = MinMaxScaler()
    scaled_data = scaler.fit_transform(data['Close'].values.reshape(-1, 1))
    return data, scaled_data, scaler


def create_sequences(data, time_steps):
    X, y = [], []
    for i in range(len(data) - time_steps):
        X.append(data[i:(i + time_steps), 0])
        y.append(data[i + time_steps, 0])
    return np.array(X), np.array(y)


def create_model(input_shape):
    model = Sequential([
        LSTM(256, return_sequences=True, input_shape=input_shape),
        LSTM(256, return_sequences=True),
        LSTM(256, return_sequences=True),
        LSTM(256, return_sequences=False),
        Dense(256),
        Dense(1)
    ])
    model.compile(optimizer='adam', loss='mean_squared_error')
    return model


def predict_stock_price(ticker, start_date, end_date, time_steps, epochs, batch_size):
    data, scaled_data, scaler = prepare_data(ticker, start_date, end_date)
    X, y = create_sequences(scaled_data, time_steps)
    X = X.reshape((X.shape[0], X.shape[1], 1))

    split = int(0.8 * len(X))
    X_train, X_test = X[:split], X[split:]
    y_train, y_test = y[:split], y[split:]

    model = create_model((X_train.shape[1], X_train.shape[2]))
    model.fit(X_train, y_train, epochs=epochs, batch_size=batch_size, validation_split=0.1, verbose=1)

    predictions = model.predict(X)
    predictions = scaler.inverse_transform(predictions)

    results = pd.DataFrame({
        'ticker': ticker,
        'date': data['Date'][time_steps:],
        'actual': data['Close'][time_steps:].values,
        'prediction': predictions.flatten().round(-2).astype(int)
    })
    
    results['difference'] = (results['prediction'] - results['actual']).astype(int)
    
    return results, model, scaler


def print_recent_days(results):
    print(results.tail(60))


def plot_results(results, ticker, days=220):
    plt.figure(figsize=(12, 6))
    
    plt.plot(results['date'][-days:], results['actual'][-days:], label='Actual', color='red')
    plt.plot(results['date'][-days:], results['prediction'][-days:], label='Prediction', color='blue')
    
    plt.title(f'{ticker} Stock Price - Recent {days} Days')
    plt.xlabel('Date')
    plt.ylabel('Price')
    plt.legend()
    
    plt.xticks(rotation=45)
    plt.tight_layout()

    base_filename = f'result{ticker}.png'
    save_path = os.path.join(SAVE_DIRECTORY, base_filename)

    counter = 1
    while os.path.exists(save_path):
        save_path = os.path.join(SAVE_DIRECTORY, f'result{ticker}({counter}).png')
        counter += 1
    
    plt.savefig(save_path)
    # plt.show()
    plt.close()
    print(f'\nPlot saved to {save_path}')

db_lock = threading.Lock()

SAVE_DIRECTORY = "/app/algorithm"

def save_to_sqlite(results, db_name, table_name='predictions'):

    if not os.path.exists(SAVE_DIRECTORY):
        os.makedirs(SAVE_DIRECTORY)

    if not db_name.endswith('.sqlite3'):
        db_name += '.sqlite3'

    db_path = os.path.join(SAVE_DIRECTORY, db_name)

    with db_lock:
        conn = sqlite3.connect(db_path)
        
        results['date'] = pd.to_datetime(results['date']).dt.date
        
        results.to_sql(table_name, conn, if_exists='append', index=False)
        conn.close()

        logger.info(f"Saving database file to: {db_path}")


def predict_next_day_price(model, scaler, results, time_steps):
    last_sequence = results['actual'].tail(time_steps).values.reshape(-1, 1)
    last_sequence_scaled = scaler.transform(last_sequence)
    last_sequence_scaled = last_sequence_scaled.reshape(1, time_steps, 1)

    next_day_prediction_scaled = model.predict(last_sequence_scaled)    
    next_day_price = scaler.inverse_transform(next_day_prediction_scaled)[0][0]
    next_day_price_rounded = round(next_day_price, -2)
    formatted_next_day_price = f"{int(next_day_price_rounded):,}"
    
    return formatted_next_day_price


def process_stock(ticker):
    results, model, scaler = predict_stock_price(ticker, start_date, end_date, time_steps, epochs, batch_size)

    # print(f"\nStock {ticker} - Last 60 Days:")
    # print_recent_days(results)

    # plot_results(results, ticker)

    db_path = os.path.join(SAVE_DIRECTORY, 'lstm_predictions')
    save_to_sqlite(results, db_name=db_path, table_name=f'predictions')

    abs_diff_mean = results['difference'].abs().mean()
    abs_diff_mean_formatted = f"{int(round(abs_diff_mean)):,}"
    print(f"\nStock {ticker} Mean of Absolute Differences: KRW {abs_diff_mean_formatted}\n")

    next_day_price_formatted = predict_next_day_price(model, scaler, results, time_steps)
    print(f"Stock {ticker} Next Day Predicted Price: KRW {next_day_price_formatted}\n\n")

    print(f"Processing stock {ticker}...")
    time.sleep(1)
    return f"Completed {ticker}"


def stock_parallel_thread(tickers):
    with ThreadPoolExecutor(max_workers=5) as executor:
        results = list(tqdm(executor.map(process_stock, tickers), total=len(tickers), desc="Processing Status:"))
        return results
    
def stock_parallel_core(tickers):
    with ProcessPoolExecutor(max_workers=2) as executor:
        results = list(tqdm(executor.map(process_stock, tickers), total=len(tickers), desc="Processing Status:"))
        return results


if __name__ == '__main__':
    results = stock_parallel_thread(tickers)
    
    print("\nResults:")
    for result in results:
        print(result)