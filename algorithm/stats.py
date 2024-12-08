import sqlite3
import pandas as pd
import os

# margin = 5000


def read_db(db_file, table_name):

    conn = sqlite3.connect(db_file)
    
    query = f"SELECT * FROM {table_name};"
    df = pd.read_sql(query, conn)
    
    conn.close()

    return df


def stats(df, margin_ratio):

    # <1> basic info
    first_date = df['Date'].min()
    last_date = df['Date'].max()

    count = df.shape[0]

    # <2> average
    avg_actual = df['Actual'].mean()
    avg_prediction = df['Prediction'].mean()
    avg_difference = df['Difference'].abs().mean()

    # <3> error range
    margin = avg_actual * margin_ratio
    count_within_range = (df['Difference'].abs() <= margin).sum()

    # <4> prediction accuracy
    accuracy = (count_within_range / count) * 100

    return first_date, last_date, count, avg_actual, avg_prediction, avg_difference, margin, count_within_range, accuracy


def print_stats(df, db_file, table_name, margin_ratio):
    df = read_db(db_file, table_name)
    file_name = os.path.basename(db_file)
        
    first_date, last_date, count, avg_actual, avg_prediction, avg_difference, margin, count_within_range, accuracy = stats(df, margin_ratio)

    print(f"\nFile Name: [{file_name}]")
    print("\n>> Basic Info")
    print(f"* first date: {first_date}")
    print(f"* last date: {last_date}")
    print(f"* number of rows: {count}")
    print()

    print(">> Average")
    print(f"* actual: {avg_actual:,.0f}")
    print(f"* prediction: {avg_prediction:,.0f}")
    print(f"* difference: {avg_difference:,.0f}")
    print()
    
    print(f">> Accuracy")
    print(f"* margin of error: {margin:,}")
    print(f"* number of data within range: {count_within_range}")
    print(f"* accuracy: {accuracy:.2f}%")

    return accuracy, margin


def print_accuracy(db_files, table_name, margin_ratio):
    print("005930 삼성전자      000660 SK하이닉스      373220 LG에너지솔루션")
    print("207940 삼성바이오로직스      005380 현대차      005935 삼성전자우")
    print("068270 셀트리온   000270 기아   105560 KB금융   005490 POSCO홀딩스\n")

    for db_file in db_files:
        file_name = os.path.basename(db_file)
        df = read_db(db_file, table_name)
        _, _, _, avg_actual, _, _, margin, _, accuracy = stats(df, margin_ratio)
        
        print(f"{file_name}: {accuracy:.2f}% (margin: {margin:,.0f})")
        # print(f"{accuracy:.2f}% ({margin:,.0f})")



def multiple_db_files(db_files, table_name, margin_ratio):
    for db_file in db_files:
        df = read_db(db_file, table_name)
        # stats_values = stats(df)
        accuracy, marin = print_stats(df, db_file, table_name, margin_ratio)    
        print()
        print()


db_files = [

]

margin_ratio = 0.02
table_name = 'predictions'

# for each file
# db = 'D:\\dev\\experiments\\previous_model_withKS\\db_241105_005930_ks.sqlite3'
# df = read_db(db, table_name)
# print_stats(df, db)

# multiple files
# multiple_db_files(db_files, table_name, margin_ratio)

# accuracy
print_accuracy(db_files, table_name, margin_ratio)