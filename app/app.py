import os
import socket
from flask import Flask, jsonify

app = Flask(__name__)

@app.get('/')
def index():
    return jsonify(application='flask-learning-lab', environment=os.getenv('APP_ENV', 'local'),
                   server=socket.gethostname(), version=os.getenv('APP_VERSION', 'development'))

@app.get('/health')
def health():
    return jsonify(status='ok'), 200
