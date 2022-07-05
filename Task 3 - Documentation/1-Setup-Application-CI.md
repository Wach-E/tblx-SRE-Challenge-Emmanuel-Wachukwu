# Task 3 - Application Continuous Integration

As previously mentioned in task-1, the nature of this repository doesn't allow for secrets addition which is needed for CI/CD processes and hence, I will document the processes I carried out in the CI/CD processes here but the execution of the pipeline can be found here: [public-sre-challenge-emmanuel-wachukwu repo](https://github.com/Wach-E/tblx-SRE-Challenge-Emmanuel-Wachukwu/tree/develop).

This document contains the different steps required to test, build and deploy the http endpoint application built in task-1 to dockerhub. To successfully carry out this task, a dockerhub account is required and the credentials of the account is passed into the pipeline as secrets. 

1. Github workflows reside in the .github/workflows directory. To create this directory:
`mkdir -p .github/workflows`

2. Create the application workflow:
`touch application.yml`

3. Open the `application.yml` file.

The first element of a workflow is its name. Add the workflow name:

```
name: Daimler-Truck WebApp CI/CD
```

Next, the file needs to know what would trigger its run. This is done with the `on` parameter. For this task, I configured the pipeline to run on `push` and `pull request` to the `develop` branch

```
on:
  push:
    branches: [develop]
  pull_request:
    branches: [ develop ]
```

Next, the jobs that will be run in this workflow needs to be configured. For this stage of the task, two jobs needs to run; test and build_deploy jobs. A job consists of majorly of its **name**, machine to run on (**runs-on**) and **steps**. Each step consists of a name and several actions. Create the test job:

```
jobs:
  test:
    runs-on: ubuntu-20.04
    steps:
      - uses: actions/checkout@v2
      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: 3.8
      - name: Install dependencies
        run: |
          cd app
          python -m pip install --upgrade pip
          pip install -r requirements.txt
      - name: Test with pytest
        run: |
          pytest

```

Terms definition:
- runs-on: Set the operating system for the github runner.
- uses: specifies a github action runner to be executed. In this case the `actions/checkout@v2` is used to checkout the existing code in the repository.
- name: Name of the step.
- with: parameter used with `uses` to pass in variables for action runners.

The test job does the following:
- Checkout of the repository on the develop branch.
- Set the python environment to python 3.8.
- Navigate to the `app` directory, install pip with its upgraded version and use pip to install the application requirements
- Test the application using `pytest`.

Next, add the build_deploy job:

```
  build_deploy:
    needs: [test]
    runs-on: ubuntu-20.04
    steps:
      - name: checkout
        uses: actions/checkout@v2
      - name: Build and push
        id: docker-build
        env:
          USER: ${{ secrets.DOCKERHUB_USERNAME }}
        run: |
          cd app
          export IMAGE_TAG=$(git rev-parse --short HEAD)
          echo "${{ secrets.DOCKERHUB_PASSWORD }}" | docker login -u ${USER} --password-stdin

          docker build --platform linux/amd64 -t sre-tblx .
          docker tag sre-tblx ${USER}/sre-tblx:${IMAGE_TAG}
          docker push ${USER}/sre-tblx:${IMAGE_TAG}
```

The parameter `env` is used to add environmental variables. The `env` parameter can exist as:
- pipeline environment variable: variables that will be used in different jobs within the pipeline.
- job environment variable: variables that will be used in several steps in a job.
- step environment variable: variables that will be used in several actions within the steps.
For this case, the step environment variable is used. The `Build ad push` action contains the **USER** variable which hold the data in `DOCKERHUB_USERNAME` secret. To add secrets to your repository:
- Navigate to the repository `Settings`.
- On the left pane, select **Secret** >> **Action**.
- Click **New repository secret**.
- Give the secret a name, `DOCKERHUB_USERNAME` and enter your dockerhub username as the value.
- Click `Add secret` button.
- Repeat the same process to add your docker password to a secret named `DOCKERHUB_PASSWORD`.

Now we know what the contents are for, here is what this job does:
- Checkout of the repository on the develop branch.
- Navigate to the app directory.
- Create an IMAGE_TAG environment variable from the short version of the latest git commit (7 digits hash)
- Login to docker using credentials stored in secrets.
- Build a docker image from the current context for linux/amd64 platform and tag it `sre-tblx`.
- Tag the built image with the dockerhub user to create a repository and append the image tag.
- Deploy the docker image to the docker repository.

Here is the complete pipeline:

```
# CI/CD Pipeline for Task 3

name: Daimler-Truck WebApp CI/CD

on:
  # Triggers the workflow on push and pull_request events for the develop branch.
  push:
    branches: [develop]
  pull_request:
    branches: [develop]

jobs:
  test:
    runs-on: ubuntu-20.04
    steps:
      - uses: actions/checkout@v2
      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: 3.8
      - name: Install dependencies
        run: |
          cd app
          python -m pip install --upgrade pip
          pip install -r requirements.txt
      - name: Test python application with pytest
        run: |
          pytest

  build_deploy:
    needs: [test]
    runs-on: ubuntu-20.04
    steps:
      - name: checkout
        uses: actions/checkout@v2
      - name: Build and push
        id: docker-build
        env:
          USER: ${{ secrets.DOCKERHUB_USERNAME }}
        run: |
          cd app
          export IMAGE_TAG=$(git rev-parse --short HEAD)
          echo "${{ secrets.DOCKERHUB_PASSWORD }}" | docker login -u ${USER} --password-stdin

          docker build --platform linux/amd64 -t sre-tblx .
          docker tag sre-tblx ${USER}/sre-tblx:${IMAGE_TAG}
          docker push ${USER}/sre-tblx:${IMAGE_TAG}
```

This process successfully test, builds and deploys the daimler web application to Docker. In the next documentation, for this task, the infrastructure deployment will be added.