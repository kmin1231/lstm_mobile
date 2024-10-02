from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name='index'),
    # path('plot_ss/', views.plot_ss, name='plot_ss'),
    path('predict/', views.predict, name='predict'),
    path('history/', views.history, name='history'),
    path('calendar_prediction/', views.calendar_prediction, name='calendar_prediction'),
]