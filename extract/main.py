import requests
import os
import json
import base64
from datetime import date, timedelta
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

def get_311_data(from_when):
    apptoken, username, password = load_creds()
    socrata_client = Socrata("data.cityofnewyork.us", 
                        apptoken, username, password)

    results = socrata_client.get("fhrw-4uyv", 
                        where = "created_date > '{}'".format(from_when),
                        limit = 8000)
    return(results) 

def fetch_and_write(data, context):
    action = base64.b64decode(data['data']).decode('utf-8')
    yesterday = date.today() - timedelta(1)
    yesterday = str(yesterday)[:10]

    if (action == "download!"):
        payload = get_311_data(yesterday) 
        payload = '\n'.join(json.dumps(item) for item in payload)

        file_name = "311data_{}.json".format(yesterday.replace("-", ""))
        storage_client.get_bucket(STORAGE_BUCKET) \
            .blob(file_name) \
            .upload_from_string(payload)
    else:
        print("No instructions received.")