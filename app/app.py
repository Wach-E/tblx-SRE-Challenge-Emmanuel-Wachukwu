import requests
import json
import html2text
import re
import logging

from flask import Flask, request, render_template
from werkzeug.wrappers import response

# Define the Flask application
app = Flask(__name__)

# Using file configuration
app.config.from_pyfile('config.py')

## Setup custom logging
# Create logger
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

# Create Handler and Formatter
handler = logging.FileHandler('daimler_trucks.log')
log_format = '%(asctime)s - %(name)s - %(levelname)s - %(funcName)s:%(lineno)d - %(message)s'
formatter = logging.Formatter(log_format)
handler.setFormatter(formatter)

# Added log_handler to logger
logger.addHandler(handler)

#Configure root logger
logging.basicConfig(filename='app_logs.log', format=log_format)

# Define the health status of the application
@app.route('/healthz')
def healthcheck():
    response=app.response_class(
        response=json.dumps({"result":"Ok-healthy"}),
        status=200,
    )
    return response

## Convert Daimler Trucks Wikipedia webpage to dictionary of words
def get_daimler_words():
    url = "https://en.wikipedia.org/wiki/Daimler_Truck"

    res = requests.get(url)
    html_page = res.text

    logger.info('Successfully retrived Daimler_Truck webpage')

    # Covert HTML to plain text
    h = html2text.HTML2Text()
    h.ignore_links = True  # Ignore converting links from HTML
    page = h.handle(html_page)

    logger.info('Converted Daimler_Truck webpage to textfile')
    # Store refined html page
    with open('daimler.txt', 'w') as file:
        file.write(page)

    # Remove urls from daimler.txt file 
    with open('daimler.txt', 'r') as file:
        string = file.read()
    # Regex for url removal
    remove_url_str_a = re.sub(r'/[/]?\S*.*[\r\n]*|http(s)?', '', string, flags=re.MULTILINE)
    latest_str_b = re.sub(r'\.png|\.svg|\.jpg', '', remove_url_str_a, flags=re.MULTILINE)
    remove_url_str_c = re.sub(r'\(\w*\)|!\[\w*.\w*\n\w*\]', '', latest_str_b, flags=re.MULTILINE)

    with open('daimler.txt', 'w') as file:
        file.write(remove_url_str_c)

    # Replace every special and numeric character with a space
    replace_char = re.sub(r'[^A-Za-z]', ' ', remove_url_str_c, flags=re.MULTILINE)

    with open('daimler.txt', 'w') as file:
        file.write(replace_char)

    # Strip multiple spaces into a single space
    file_input = open('daimler.txt', 'r')
    file_output = open('daimler-output.txt', 'w')

    for line in file_input:
        file_output.write(' '.join(line.split()))

    file_input.close()
    file_output.close()

    # Convert every character to lower case
    with open('daimler-output.txt','r') as source:
        open('daimler-lower.txt', 'w').close()
        for line in source.read():
            lower_case = line.lower()
            with open('daimler-lower.txt', 'a') as file:
                file.write(lower_case)

    word_count = {}
    words = []

    # Convert each word in file to a list element
    with open('daimler-lower.txt','r') as file:
        # reading each line
        for line in file:
            # reading each word
            for word in line.split():
                # displaying the words
                if len(word) < 3 :
                    continue
                else:
                    words.append(word)

    # Covert list of words to dictionary
    for word in words:
        if word in word_count.keys() :
            word_count[word] = word_count.get(word) + 1
        else:
            word_count[word] = 1

    # Sort word_count dictioary
    word_list = dict(sorted(word_count.items(), key=lambda x: x[1], reverse=True))
    return word_list

# Obtain the endpoint
@app.route('/api/v1/daimler_truck', methods=['GET'])
def home():
    word_list = get_daimler_words()
    return render_template("home.html", word_list=word_list)


# start the application on port 8000
if __name__ == "__main__":
   app.run(host='0.0.0.0', port='8000')
