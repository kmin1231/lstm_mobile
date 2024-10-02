from django.core.management.base import BaseCommand
from lstm.algorithm import get_prediction

class Command(BaseCommand):
    help = 'Run the prediction algorithm'

    def handle(self, *args, **options):
        print("Starting prediction...")
        prediction_results = get_prediction()
        print("Prediction finished.")
        # for date, prediction in prediction_results:
            # print(f'Prediction for {date.strftime("%Y-%m-%d")}: {prediction}')