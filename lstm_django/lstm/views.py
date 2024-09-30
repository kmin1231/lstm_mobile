import os, io, base64,sys
sys.path.append('C:\\Users\\min\\Desktop\\lstm\\lstm')
from django.shortcuts import render
# from django.http import HttpResponse
from django.http import JsonResponse
from .models import SS, KS, load_ss, load_ks, Prediction
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from datetime import date, datetime, timedelta
from django.conf import settings
from .prediction import getprediction, predict_graph, history_data, calculate_accuracy, predict_start

# def index(request):
#     return HttpResponse("testing...!")


def index(request):
    today = date.today()
    context = {'ss_graph': plot_ss(), 'today': today}
    return render(request, 'main.html', context)

def predict(request):
    context = {'predictions': getprediction(),
               'prediction_graph': predict_graph()}
    return render(request, 'predict.html', context)

def history(request):
    predictions = history_data(predict_start)
    monthly_accuracy = calculate_accuracy(predictions)
    predictions.sort(key=lambda x: x[0], reverse=True)
    context = {
        'predictions': predictions,
        'monthly_accuracy': monthly_accuracy
    }
    return render(request, 'history.html', context)


def plot_ss():
    today = date.today()
    end_date = today

    # start_date = end_date - timedelta(days=29)
    # ss_prices = SS.objects.filter(date__range=(start_date, end_date)).order_by('date')

    start_date = '2024-01-01'
    ss_prices = SS.objects.filter(date__range=(start_date, end_date)).order_by('date')

    dates = [price.date for price in ss_prices]
    close = [price.close for price in ss_prices]

    plt.figure(figsize=(7, 4))
    plt.plot(dates, close, label='Close Price', color='#e35f62')
    plt.xlabel('Date')
    plt.ylabel('Close')
    # plt.title('최근 삼성전자 실제 주가')

    max_close = max(close)
    min_close = min(close)

    plt.annotate(f'Max: {int(max_close)}', xy=(dates[close.index(max_close)], max_close),
                 xytext=(-80, -5), textcoords='offset points', arrowprops=dict(arrowstyle='-|>'))
    plt.annotate(f'Min: {int(min_close)}', xy=(dates[close.index(min_close)], min_close),
                 xytext=(15, 0), textcoords='offset points', arrowprops=dict(arrowstyle='-|>'))

    plt.legend()
    plt.grid(True)
    plt.xticks(rotation=30)
    plt.tight_layout()

    img_data = io.BytesIO()
    plt.savefig(img_data, format='png')
    plt.close()
    img_data.seek(0)
    ss_graph = base64.b64encode(img_data.read()).decode('utf-8')

    context = {'ss_graph': ss_graph, 'today': today}
    return ss_graph
    # return render(request, 'main.html', context)

end_date = datetime.now().strftime('%Y-%m-%d')
load_ss(start_date='2022-01-01', end_date=end_date)
load_ks(start_date='2022-01-01', end_date=end_date)


def calendar_prediction(request):
    date = request.GET.get('date')
    print('Requested date:', date)

    if not date:
        return JsonResponse({'error': 'No date provided'}, status=400)

    try:
        prediction = Prediction.objects.get(date=date)
        print('Prediction:', prediction.prediction)
        return JsonResponse({'date': prediction.date, 'prediction': prediction.prediction})
    except Prediction.DoesNotExist:
        print('Prediction not found for date:', date)
        return JsonResponse({'error': 'Prediction not found for the given date'}, status=404)
