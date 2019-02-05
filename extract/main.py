import requests
import datetime
import os
import json
from sodapy import Socrata
from google.cloud import storage

storage_client = storage.Client()
SECRET_BUCKET = os.environ['SECRET_BUCKET']
STORAGE_BUCKET = os.environ['STORAGE_BUCKET']

def load_creds():
    blob = storage_client.get_bucket(SECRET_BUCKET) \
        .get_blob('creds.json') \
        .download_as_string()

    parsed = json.loads(blob)

    apptoken = parsed['apptoken']
    username = parsed['username']
    password = parsed['password']

    return apptoken, username, password

def get_311_data(from_when, limit):
    apptoken, username, password = load_creds()
    socrata_client = Socrata("data.cityofnewyork.us", 
                        apptoken, username, password)

    results = socrata_client.get("fhrw-4uyv", 
                        where = "created_date > '{}'".format(from_when),
                        limit = limit)
    return(results) 

def fetch_and_write(request):
    request_json = request.get_json()
    date = request_json['date']
    limit = request_json['limit']

    data = get_311_data(date, limit) 
    data = '\n'.join(json.dumps(item) for item in data)

    file_name = "311data_{}.json".format(date.replace("-", ""))
    storage_client.get_bucket(STORAGE_BUCKET) \
        .blob(file_name) \
        .upload_from_string(data)