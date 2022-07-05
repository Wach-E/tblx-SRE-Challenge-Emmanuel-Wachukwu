# Task 1 - Virtual environment setup

To setup the virtualenv, the application repository needs to be cloned.
1. Clone challenge github repository
`git clone git@github.com:tblxio/tblx-challenge-sre-Emmanuel-Wachukwu.git`
N/B: I used the ssh cloning method as it offers no manual token input once the public ssh key has been added to Github.
2. Navigate to the cloned repo:
`cd tblx-challenge-sre-Emmanuel-Wachukwu`
3. For this project, **github feature (task-*) workflow develop** branching pattern will be implemented:
`git checkout -b develop`
`git checkout -b task-1`
4. Create a folder to hold the application files:
`mkdir app`
5. Create a virtualenv for all the project dependecies:
`python3 -m venv media-wiki`
The above command creates a new directory which can be viewed:
`ls media-wiki`
The files within this folder work to ensure the python project is isolated from the broader context of the server so files don't mix up.
6. To use this environment, we need to activate it, which you can achieve by typing the following command that calls the activate script:
`source media-wiki/bin/activate`
Your command prompt will now be prefixed with the name of your environment, **media-wiki**
`(media-wiki) ubuntu@ip:~/tblx-challenge-sre-Emmanuel-Wachukwu/app$`
7. To begin our application development we need to create the application and requirements file:
`touch app.py requirements.txt`
