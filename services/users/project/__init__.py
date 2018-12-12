from flask import Flask, jsonify
import sys, os


# instantiate the app
app = Flask(__name__)

app_settings = os.getenv('APP_SETTINGS')  # new
app.config.from_object(app_settings)      # new

@app.route('/users/ping', methods=['GET'])
def ping_pong():
    return jsonify({
        'status': 'success',
        'message': 'pong!'
    })
