from django.core.management.base import BaseCommand
from lstm.algorithm import get_prediction
from datetime import datetime
import os

class Command(BaseCommand):
    help = 'Run the prediction algorithm'

    def handle(self, *args, **options):
        print("Starting prediction...")
        prediction_results = get_prediction()
        print("Prediction finished.")
        # for result in prediction_results:
        #     if isinstance(result[0], str):
        #         date = datetime.strptime(result[0], "%Y-%m-%d")
        #     else:
        #         date = result[0]
            
        #     prediction = result[1]
        #     print(f'Prediction for {date.strftime("%Y-%m-%d")}: {int(prediction)}')