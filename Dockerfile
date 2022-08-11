FROM nvcr.io/nvidia/cuda:11.6.0-cudnn8-devel-ubuntu20.04

LABEL Arthur="Shankar Mounesh" Description="A docker image with cuda and python runtime support"

# Stop dpkg-reconfigure tzdata from prompting for input
ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update && \
    apt-get install -y  apt-utils \
    curl \
    python3 \  
    pip \
    python3-pip 

RUN update-alternatives --install /usr/local/bin/python python /usr/bin/python3 40

EXPOSE 8080
    