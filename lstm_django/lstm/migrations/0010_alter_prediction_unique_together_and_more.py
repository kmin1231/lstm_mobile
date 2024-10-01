# Generated by Django 5.0.6 on 2024-06-07 18:54

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('lstm', '0009_alter_prediction_date'),
    ]

    operations = [
        migrations.AlterUniqueTogether(
            name='prediction',
            unique_together=set(),
        ),
        migrations.AlterField(
            model_name='prediction',
            name='actual',
            field=models.FloatField(),
        ),
        migrations.AlterField(
            model_name='prediction',
            name='date',
            field=models.DateField(unique=True),
        ),
    ]
