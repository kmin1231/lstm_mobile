# Generated by Django 5.0.6 on 2024-06-04 19:31

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('lstm', '0003_prediction_difference'),
    ]

    operations = [
        migrations.AlterField(
            model_name='prediction',
            name='actual',
            field=models.FloatField(null=True),
        ),
        migrations.AlterField(
            model_name='prediction',
            name='difference',
            field=models.FloatField(null=True),
        ),
    ]