import io, base64
import FinanceDataReader as fdr
import pandas as pd
import numpy as np
from .models import SS, load_ss, Prediction
from datetime import datetime, timedelta
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import train_test_split
from keras.models import Sequential, load_model
from keras.layers import LSTM, Dense, Dropout, Flatten
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error
from scipy.interpolate import splrep, splev

predict_start = '2024-01-01'

def getprediction():
    model2 = load_model('C:\\Users\\min\\Desktop\\lstm\\lstm\\lstm_model.h5')

    time_step = 10
    epochs = 100
    batch_size = 8
    prediction_results = []

    end_date = datetime.today().strftime('%Y-%m-%d')
    current_date = datetime.strptime(predict_start, '%Y-%m-%d')
    
    while current_date <= datetime.strptime(end_date, '%Y-%m-%d'):
        ahead = current_date - timedelta(days=30)
        
        try:
            existing_prediction = Prediction.objects.get(date=current_date)
            prediction_results.append((current_date, existing_prediction.prediction))
            print(f"Prediction for {current_date.strftime('%Y.%m.%d')} already exists: {int(existing_prediction.prediction)}")
            current_date += timedelta(days=1)
            continue
        except Prediction.DoesNotExist:
            pass

        try:
            df_ss = fdr.DataReader('005930', ahead, current_date)
            df_ks = fdr.DataReader('KS11', ahead, current_date)

            df_ss_common = df_ss[df_ss.index.isin(df_ks.index)]
            df_ks_common = df_ks[df_ks.index.isin(df_ss.index)]

            df_ss_common.dropna(inplace=True)
            df_ks_common.dropna(inplace=True)

            if df_ss_common.empty:
                print(f"No common dates found for {current_date}")
                current_date += timedelta(days=1)
                continue

            if current_date in df_ss_common.index:
                ss_close = df_ss_common.loc[current_date, 'Close']
                ks_close = df_ks_common.loc[current_date, 'Close']

                ss_close = df_ss_common['Close'].values.reshape(-1, 1)
                ks_close = df_ks_common['Close'].values.reshape(-1, 1)

                scaler_ss = MinMaxScaler()
                scaler_ks = MinMaxScaler()

                scaled_ss = scaler_ss.fit_transform(ss_close.reshape(-1, 1))
                scaled_ks = scaler_ks.fit_transform(ks_close.reshape(-1, 1))

                combined_data = []
                for i in range(len(scaled_ss) - time_step):
                    combined_data.append(np.concatenate((scaled_ss[i:i+time_step], scaled_ks[i:i+time_step]), axis=1))
                combined_data = np.array(combined_data)
                X_train, X_test, y_train, y_test = train_test_split(combined_data[:, :-1], combined_data[:, -1], test_size=0.1, random_state=42)

                model2.fit(X_train, y_train, epochs=epochs, batch_size=batch_size)
                predicted_data_scaled = model2.predict(X_test)
                predicted_data = scaler_ss.inverse_transform(predicted_data_scaled)
                prediction = predicted_data[-1][0]

                actual_value = ss_close[-1][0]
                difference = actual_value - prediction

                Prediction.objects.create(date=current_date, prediction=prediction, actual=actual_value, difference=difference)

                prediction_results.append((current_date, prediction))
                print(f'Prediction for {current_date.strftime("%Y.%m.%d")} : {prediction}')

        except ValueError as e:
            print(f"Skipping {current_date}: {e}")
            pass

        current_date += timedelta(days=1)
    return prediction_results

def predict_graph():
    today = datetime.today().strftime('%Y-%m-%d')
    # predict_start = '2024-04-01'

    # Get actual data from the database
    ss_prices = SS.objects.filter(date__range=(predict_start, today)).order_by('date')
    dates = [price.date for price in ss_prices]
    close = [price.close for price in ss_prices]

    df_actual = pd.DataFrame({'Date': dates, 'Close': close})
    df_actual['Date'] = pd.to_datetime(df_actual['Date'])
    df_actual.set_index('Date', inplace=True)
    df_actual = df_actual[~df_actual.index.duplicated(keep='first')]

    plt.figure(figsize=(8, 4))

    if not df_actual.empty:
        date_nums_actual = matplotlib.dates.date2num(df_actual.index)
        spl_actual = splrep(date_nums_actual, df_actual['Close'], s=0)
        date_nums_actual_smooth = np.linspace(date_nums_actual.min(), date_nums_actual.max(), 500)
        close_actual_smooth = splev(date_nums_actual_smooth, spl_actual)
        dates_actual_smooth = matplotlib.dates.num2date(date_nums_actual_smooth)
        plt.plot(dates_actual_smooth, close_actual_smooth, label='Actual', color='#1f77b4')

    # Get prediction data from the database
    predictions = Prediction.objects.filter(date__range=(predict_start, today)).order_by('date')
    prediction_results = [(prediction.date, prediction.prediction) for prediction in predictions]

    df_prediction = pd.DataFrame(prediction_results, columns=['Date', 'Prediction'])
    df_prediction['Date'] = pd.to_datetime(df_prediction['Date'])
    df_prediction.set_index('Date', inplace=True)

    if not df_prediction.empty:
        date_nums_prediction = matplotlib.dates.date2num(df_prediction.index)
        spl_prediction = splrep(date_nums_prediction, df_prediction['Prediction'], s=0)
        date_nums_prediction_smooth = np.linspace(date_nums_prediction.min(), date_nums_prediction.max(), 500)
        close_prediction_smooth = splev(date_nums_prediction_smooth, spl_prediction)
        dates_prediction_smooth = matplotlib.dates.num2date(date_nums_prediction_smooth)
        plt.plot(dates_prediction_smooth, close_prediction_smooth, label='Prediction', color='orange')

    plt.xlabel('Date')
    plt.ylabel('Price')
    plt.xticks(rotation=30)
    # plt.yticks(np.arange(74000, 82000, 1000)) 
    plt.grid(True)
    plt.legend()
    plt.tight_layout()

    min_value = min(df_actual['Close'].min(), df_prediction['Prediction'].min())
    max_value = max(df_actual['Close'].max(), df_prediction['Prediction'].max())
    interval = 2000
    plt.yticks(np.arange(int(min_value), int(max_value) + interval, interval))

    img_data = io.BytesIO()
    plt.savefig(img_data, format='png')
    plt.close()
    img_data.seek(0)
    graph_img = base64.b64encode(img_data.read()).decode('utf-8')

    return graph_img


def history_data(predict_start):
    today = datetime.today().strftime('%Y-%m-%d')
    predictions_exist = Prediction.objects.filter(date__range=(predict_start, today)).exists()

    if predictions_exist:
        predictions = Prediction.objects.filter(date__range=(predict_start, today)).order_by('date')
        prediction_data = [(pred.date, pred.actual, pred.prediction, pred.difference) for pred in predictions]
    else:
        ss_prices = SS.objects.filter(date__range=(predict_start, today)).order_by('date')

        dates = [price.date for price in ss_prices]
        close = [price.close for price in ss_prices]

        df_actual = pd.DataFrame({'Date': dates, 'Actual': close})
        df_actual.set_index('Date', inplace=True)

        for index, row in df_actual.iterrows():
            if not Prediction.objects.filter(date=index).exists():
                try:
                    prediction_object = Prediction.objects.create(date=index, actual=row['Actual'])
                    prediction_object.difference = prediction_object.actual - prediction_object.prediction
                    prediction_object.save()
                except Prediction.DoesNotExist:
                    print(f"No prediction found for {index}")

        predictions = Prediction.objects.filter(date__range=(predict_start, today)).order_by('date')
        prediction_data = [(pred.date, pred.actual, pred.prediction, pred.difference) for pred in predictions]

    return prediction_data


from collections import defaultdict

def calculate_accuracy(predictions): 
    monthly_counts = defaultdict(lambda: {'good_predictions': 0, 'total_predictions': 0})
    
    for i in range(1, len(predictions)):
        current_date, current_actual, current_prediction, current_difference = predictions[i]
        previous_date, previous_actual, _, _ = predictions[i - 1]

        if current_actual is not None and current_prediction is not None and previous_actual is not None and current_date.year == 2024 and current_date.month <= 5:
            predicted_direction = current_prediction - previous_actual
            actual_direction = current_actual - previous_actual

            if predicted_direction * actual_direction > 0: 
                monthly_counts[current_date.strftime('%Y-%m')]['good_predictions'] += 1

            monthly_counts[current_date.strftime('%Y-%m')]['total_predictions'] += 1

    monthly_accuracy = {}
    for month, counts in monthly_counts.items():
        if counts['total_predictions'] > 0:
            monthly_accuracy[month] = (counts['good_predictions'] / counts['total_predictions']) * 100
        else:
            monthly_accuracy[month] = 0

    return monthly_accuracy
