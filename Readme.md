## Gpu acclerated docker image with python3

* This dockerfile includes a python3 with cuda cudatoolkit cudnn for gpu acceleration ml model training
* To install docker nvidia-container runtime all in one shot use docker.sh file
* The nviida-driver is also containered in docker 
* Run the python-docker.sh file in the projects root folder for creating a contaier without any burderns


## Steps to run

Clone the repo and give execution permissions 

```sh
chmod +x python-docker.sh docker.sh
./docker.sh
```
- It will install the docker nvidia-container runtime and update the kernel and reboot the system which is necessary for the proper running of driver container 


```sh
./python-docker.sh 
```

- The above command should be run in  the projects root folder which will mount the volume of current working directory inside the container and also create the driver container.



## Jupyter-lab 

Install notebook using pip

```sh
pip install notebook
```

Run jupyter notebook using the below command

```sh
jupyter notebook --notebook-dir=$(pwd) --ip 0.0.0.0 --no-browser --allow-root --NotebookApp.allow_origin='https://colab.research.google.com' --port=8888 --NotebookApp.port_retries=0
```