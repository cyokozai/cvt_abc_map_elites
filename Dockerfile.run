###################### BUILDER ######################
FROM julia:latest

SHELL ["/bin/bash", "-c"]

ARG lang="C"
ARG dir="src"

ENV DEBIAN_FRONTEND noninter active
ENV TERM xterm
ENV DISPLAY host.docker.internal:0.0
ENV LANG ${lang}
ENV LANGUAGE ${lang}
ENV LC_ALL ${lang}
ENV TZ=Asia/Tokyo
ENV TZ JST-9

WORKDIR /root
COPY ./pkginstall.jl /root

RUN apt -y update && apt -y upgrade &&\
    export JULIA_NUM_THREADS=4 &&\
    julia pkginstall.jl &&\
    rm -rf ./pkginstall.jl

WORKDIR /root/${dir}
COPY ./${dir}/*.jl /root/${dir}