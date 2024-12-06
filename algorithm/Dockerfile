FROM python:3.10.13-slim-bullseye

WORKDIR /app

COPY requirements.txt .

RUN pip install --upgrade pip

RUN pip install -r requirements.txt

COPY . .

CMD ["python", "lstm.py"]
