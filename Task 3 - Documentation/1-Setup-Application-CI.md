# Application Continuous Integration

My choice of tool for CI/CD is Github Actions. Github Actions is a Cloud agnostic continuous integration/ continuous delivery tool that solves the problem of on-prem server overhead and public cloud vendor lock-in by offering integration with any type of cloud provider while abstracting server provisioning. Github Action pipelines are called workflows.

As previously mentioned in task 1, the nature of this repository doesn't allow for secrets addition which is needed for CI/CD processes and hence, I will document the processes I carried out in the CI/CD processes here but the execution of the pipeline can be found in the `develop` branch of this repo [pulic-sre-challenge-emmanuel-wachukwu repo](https://github.com/Wach-E/tblx-SRE-Challenge-Emmanuel-Wachukwu/tree/develop).

This document contains the different steps required to test, build and deploy the http endpoint application to dockerhub. To successfully carry out this task, a dockerhub account is required and the credentials of the account is passed into the pipeline as secrets. 

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
Next, the jobs that will be run in this workflow needs to be configured. For this tack, two jobs needs to run; test and build_deploy jobs. A job consists of majorly of its name, machine to run on (**runs-on**) and `steps`. Each step consists of a name and several actions. Create the test job:
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
    needs: test
    runs-on: ubuntu-20.04
    outputs:
      imagetag: ${{ steps.docker-build.outputs.IMAGE_TAG }}
    steps:
      - name: checkout
        uses: actions/checkout@v2
      - name: Build and push
        id: docker-build
        env:
          USER: ${{ secrets.DOCKERHUB_USERNAME }}
          PWD: ${{ secrets.DOCKERHUB_PASSWORD }}
        run: |
          cd app
          export IMAGE_TAG=$(git rev-parse --short HEAD)
          echo "$PWD" | docker login -u $USER --password-stdin

          docker build --platform linux/amd64 -t sre-tblx .
          docker tag sre-tblx ${USER}/sre-tblx:${IMAGE_TAG}
          docker push ${USER}/sre-tblx:${IMAGE_TAG}
          echo "::set-output name=image-tag::$IMAGE_TAG"

```
The parameter `env` is used to add environmental variables. There `env` parameter can exist as:
- pipeline environment variable: variables that will be used in different jobs within the pipeline.
- job environment variable: variables that can be used within a job.
- step environment variable: variables that will be used in several actions within the steps.
For this case, we will be using the action environment variable. The `Build ad push` action contains the user and password variables which hold the data in `DOCKERHUB_USERNAME` and `DOCKERHUB_PASSWORD` secrets. To add secrets to your repository:
- Navigate to the repository `Settings`.
- On the left pane, select Secret >> Action.
- Click `New repository secret`.
- Give the secret a name, `DOCKERHUB_USERNAME` and enter your dockerhub username as the value.
- Click `Add secret` button.
- Repeat the above steps for `DOCKERHUB_PASSWORD`.

Some new terms were added to this job; `outputs`, `id` and `::set-output name=image-tag::$IMAGE_TAG`. Here's what they do:
- outputs: this is a job level parameter that specifies the output from a job of which can be used in any job that depends on it.
- id: this is a step level parameter that identifies an action. It is useful when setting the output of a step to be used by another step.
- "::set-output name=output_name::output_value": this is used to export a step output by specifying its name and value. The output is imported by another step using `${{steps.step_id.outputs.output_name}}`.

Now we know what the contents are for, here is what this job does:
- Checkout of the repository on the develop branch.
- Navigate to the app directory.
- Create an IMAGE_TAG environment variable from the short version of the latest git commit (7 digits hash).
- Login to docker using `USER` and `PWD` step environment variables.
- Build a docker image from the current context for linux/amd64 platform and tag it `sre-tblx`.
- Tag the built image with the docker hub user to create a repository and append the image tag.
- Deploy the docker image to the docker repository.
- Create an step output called `imagetag`.
N/B: the **image-tag** output from the `Build and push` step is sustituted as the `build_deploy` job output, **imagetag**.

Here is the full complete pipeline:

```
# CI/CD Pipeline for Task 3

name: Daimler-Truck WebApp CI/CD

on:
  # Triggers the workflow on push events only for the main branch.
  push:
    branches: [develop]
  pull_request:
    branches: [ develop ]

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

  build_deploy:
    needs: test
    runs-on: ubuntu-20.04
    outputs:
      imagetag: ${{ steps.docker-build.outputs.image-tag }}
    steps:
      - name: checkout
        uses: actions/checkout@v2
      - name: Build and push
        id: docker-build
        env:
          USER: ${{ secrets.DOCKERHUB_USERNAME }}
          PWD: ${{ secrets.DOCKERHUB_PASSWORD }}
        run: |
          cd app
          export IMAGE_TAG=$(git rev-parse --short HEAD)
          echo "${PWD}" | docker login -u ${USER} --password-stdin

          docker build --platform linux/amd64 -t sre-tblx .
          docker tag sre-tblx ${USER}/sre-tblx:${IMAGE_TAG}
          docker push ${USER}/sre-tblx:${IMAGE_TAG}
          echo "::set-output name=image-tag::$IMAGE_TAG"
```

This process successfully test, builds and deploys the daimler web application to Docker. In the next documentation,for this task, the infrastructure deployment will be added



