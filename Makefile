.PHONY: all install_julia install_python install_jinja2

all: install_julia install_python install_jinja2

install-julia:
    curl -fsSL https://install.julialang.org | sh
	. ~/.bashrc
	julia pkginstall.jl

install-python:
    sudo apt -y install python3-pip

install-jinja2:
    pip install jinja2