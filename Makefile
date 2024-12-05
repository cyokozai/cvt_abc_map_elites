.PHONY: all install_julia install_python install_jinja2

all: install_julia install_python install_jinja2

install-docker:
    install-docker:
        sudo apt-get update
        sudo apt-get install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo apt-get update
        sudo apt-get install -y docker-ce

install-julia:
    curl -fsSL https://install.julialang.org | sh
	. ~/.bashrc

install-python:
    sudo apt -y install python3-pip

install-jinja2:
    pip install jinja2