import os, sys
from google.cloud import firestore
import django
from datetime import datetime
# from lstm.models import Prediction

# Django 설정 로드
# sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../lstm_django')
# os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
# django.setup()
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'lstm_django')))
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = os.path.join(os.path.dirname(__file__), '..', '..', 'backend', 'lstm-f254d.json')


os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
django.setup()
# sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'lstm_django')))


# Firestore 인증 정보 설정

# Django 설정 로드

# django.setup()

from .models import Prediction

db = firestore.Client()

def sync_to_firestore(date):
    try:
        prediction_instance = Prediction.objects.get(date=date)
        prediction_data = {
            'prediction': prediction_instance.prediction,
            'actual': prediction_instance.actual,
            'difference': prediction_instance.difference
        }
        
        doc_ref = db.collection('predictions').document(date.strftime('%Y-%m-%d'))
        doc_ref.set(prediction_data)
        print(f'Synced prediction for {date.strftime("%Y-%m-%d")} to Firestore.')
    except Prediction.DoesNotExist:
        print(f'No prediction found for {date.strftime("%Y-%m-%d")}.')

if __name__ == "__main__":
    today = datetime.today()
    sync_to_firestore(today)