FROM python:3.10.13-slim-bullseye

WORKDIR .

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .

CMD ["python", "lstm.py"]
