#!/bin/bash

# Filename: /usr/local/bin/python-docker
# Script to run python:latest inside an ephemeral docker container
# pip install python modules if requirements.txt is preset

#Creating nvidia-driver container
docker run --name nvidia-driver -d --privileged --pid=host \
  -v /run/nvidia:/run/nvidia:shared \
  -v /var/log:/var/log \
  --restart=always \
  docker.bitsathy.ac.in/nvidia/driver:515.48.07-ubuntu22.04

# do not continue script on errors
set -euo pipefail

# Get current user details so we can run python with this user id later
X_UID=$(id -u)
X_USERNAME=$(id -un)

# Set docker container name to basename of current working dir + random string
NAME=$(echo $(basename "2${PWD}" ).${RANDOM})

# Create temporary docker ENTRYPOINT shell script
X_TMPDIR="$(mktemp -d)"
ENTRYPOINT="${X_TMPDIR}/entrypoint.sh"
# Remove temp files on exit
trap "{ rm -rf ${X_TMPDIR}; }" EXIT
STATUS_CODE=$(curl -s -o /dev/null -w '%{http_code}' https://pip.bitsathy.ac.in)

cat > "${ENTRYPOINT}" <<EOF
#!/bin/bash

# Alternate entrypoint for python docker image
# Run pip as root, then run python as X_USERNAME

# do not continue script on errors
set -euo pipefail

# Optimize pip for docker usage
export ENV PIP_DISABLE_PIP_VERSION_CHECK=1
export ENV PIP_NO_CACHE_DIR=1

# create the current user in the container
useradd -u ${X_UID} -U -s /bin/bash -M ${X_USERNAME}
# usermod -aG video ${X_UID}

#install libraries using pip1
if [ ${STATUS_CODE} -eq 200 ]; then
    [ -f requirements.txt ] && pip install -r requirements.txt --index-url https://pip.bitsathy.ac.in/index
else
    [ -f requirements.txt ] && pip install -r requirements.txt
fi

# run python
# exec su -c "python $@" ${X_USERNAME}


EOF

chmod 755 ${ENTRYPOINT}

# Run python in docker with all the containers set

sudo docker run -it --rm \
        -v /etc/timezone:/etc/timezone:ro \
        -v /etc/localtime:/etc/localtime:ro \
        --gpus all \
        -v /$(pwd):/$(pwd) \
        -v ${X_TMPDIR}:${X_TMPDIR} \
        -w $(pwd) \
        --entrypoint "${ENTRYPOINT}" \
        --name ${NAME} \
        --net=host \
        docker.bitsathy.ac.in/nvidia/cuda:11.6.0-cudnn8-devel-ubuntu20.04 bash
