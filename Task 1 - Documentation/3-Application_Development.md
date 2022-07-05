# Task 1 - Application Development

To achieve the goal of converting the contents of `Daimler Truck` wikipedia page to a word list, I decided to take the following decisions in the creation of my application logic:

1. Logic Workflow:
Python is comes with the simplicity for testing, logging and development web applications. My choice of python was majorly because of its ease to integrate some of the core requirements of this task. My logic workflow as seen in `app.py` were as follows:
- Create a health check endpoint `/healthz` to confirm the reachability of the application. This is useful if an application needs to meet certain scalability criteria. For instance, cloudwatch requires to check the health status of target groups.
- Create a get webpage function `get_daimler_words()` to perform the following:
    - Request Daimler Truck Wikipedia page using `requests` module,
    - Transform the page response from html to text using `html2text` module and write to a text file (ignoring all links in html),
    - Read the text file contents and scrape all uploaded or static endpoints using regex pattern substitution,
    - Replace special and numeric characters with spaces (as they do not constitute words),
    - Strip file content with several spaces to a single space for readability and iteration,
    - Lower the case of every character to better suit data collection,
    - Loop through each word and count its number of occurence,
    - Sort the returned word list in descending order,
- Lastly, create the application api endpoint to return the word list displayed with a UI

The flask app configuration was setup in a .env file which reads the `SECRET_KEY='#key'` and `FLASK_ENV='production'`. If this application would like to be tested locally, simply copy the contents from `.env.example` to your `.env ` file. To keep the applicatio simple, the their was not strick dependence placed on the .env file and hence, the application can work with its corrent default .env variables.

2. Logging:
Python comes with an in-built logginng module called `logging` which I utilized to produce logs to two files `app_logs.log` and `daimler_truck.log`. The  `app_logs.log` contains all the logs read from the root logger while the `daimler_truck.log` contains logs read from the custom logger. I seperated the two log files because I imagined that it would be easier to have direct visibility of core business concentric logs seperate from all logs entering the application.

3. Testing:
Pytest was used to create and run the unit tests for this application. The core emphasis for the test was to confirm the function returned a list, with cotents greater than or equal to the max value and the leader word as `daimler`. The use of this test is shown in the CI/CD pipeline of task-3.

4. Containerization:
Docker was used as the container runtime for this application. The build context as properly commented in the `Dockerfile` was used to create a container image. The `.dockerignore` was used to restrict files that have no effect with the functionality of the container image.

5. CI/CD:
For the purpose of this task, I created a workflow `application.yml` in the `.github/workflows` directory. This workflow contains two jobs:
- `test`: Test python web app with `pytest`
- `build_deploy`: Build web application and deploy to dockerhub registry.
N/B: The structure of this particular `tblxio/tblx-challenge-sre-Emmanuel-Wachukwu` setup doesn't give me access to directly add secrets and as such, the `build_deploy` job will not work. Out of curiosity though, I created my own repo implemented the CI/CD pipeline workflow which test, built and deployed the application artifact to dockerhub. The artifact was locally tested as shown in step `6`. Further discussion on the CI/CD processes implemented will be discussed in **task-3**.

6. Confirm application artifact is working:
On successful deployment to dockerhub, the application was tested in a linux environment as follows:
- Create a container with the application image
`docker run -d -p 8000:8000 --name test -e SECRET_KEY='#key' -e FLASK_ENV='production' wache/sre-tblx:4abdcfa`
- Navigate to a browser and enter:
`ip_address:8000/api/v1/daimler_truck`
