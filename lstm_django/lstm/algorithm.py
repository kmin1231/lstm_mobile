import sys, os
import django, django.conf

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
django.setup()

import json
import numpy as np
import pandas as pd
import FinanceDataReader as fdr
from datetime import datetime, timedelta
from sklearn.preprocessing import MinMaxScaler
from keras.models import load_model
from sklearn.model_selection import train_test_split
from lstm.models import Prediction

predict_start = '2024-01-01'

def get_prediction():
    model2 = load_model('D:\\dev\\lstm_mobile\\lstm_django\\lstm\\lstm_model.h5')

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
            prediction_results.append((current_date.strftime('%Y-%m-%d'), existing_prediction.prediction))
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

                prediction_results.append((current_date.strftime('%Y-%m-%d'), prediction))
                print(f'Prediction for {current_date.strftime("%Y.%m.%d")} : {int(prediction):,.0f}')

        except ValueError as e:
            # print(f"Skipping {current_date}: {e}")
            pass

        current_date += timedelta(days=1)
    
    return prediction_results

if __name__ == "__main__":
    get_prediction()