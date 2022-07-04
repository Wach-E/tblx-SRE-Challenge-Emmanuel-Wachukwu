# Task 1

## Operating system
For the purpose of this task, I will be using the Gnome/Linux os. Specifically Ubuntu 20.04 of the Debian family. (AWS EC2 - t2.medium)

## Setting up Python 3: 
By default, Ubuntu 20.04 comes with python3. In this section, the goal is to prepare our os for python development
1. Update Ubuntu OS
`sudo apt update`
2. Uograde the packages installed on Ubuntu OS
`sudo apt -y upgrade`
3.  To confirm the python version:
`python3 -V`
Your output:
`Python 3.8.10`
4. For the management of python packages, [pip](https://linuxize.com/post/how-to-install-pip-on-ubuntu-20.04/) is used. Install pip:
`sudo apt install -y python3-pip`
5. For a robust setup, some packages needs to be added to the environment:
`sudo apt install -y build-essential libssl-dev libffi-dev python3-dev`

Virtual environments enable project isolation within a server for Python projects, ensuring that each of project have its own set of dependencies that won’t disrupt any of other project(s). A virtual environment can be setup using the **venv** module.
6. Install **venv**:
`sudo apt install -y python3-venv`

Extra: The containerized web application will need to be tested using docker. To setup docker on the linux environment:
7. Install docker
`sudo apt install docker.io`
8. Add current user to docker group
`sudo adduser ${USER} docker
9. You might have to log-out for the chage i step 8 to reflect.