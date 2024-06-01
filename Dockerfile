###################### BUILDER ######################
FROM ubuntu:latest AS builder

SHELL ["/bin/bash", "-c"]

WORKDIR /root

ARG lang="C"
ARG dir="workdir"

ENV DEBIAN_FRONTEND = noninter active
ENV TERM xterm
ENV DISPLAY host.docker.internal:0.0

#~~~~~~~~~~~~~~~~~~~~~~ EDIT ~~~~~~~~~~~~~~~~~~~~~~~#

COPY *.jl /root/

RUN apt -y update && apt -y upgrade &&\
    apt -y install tzdata \
    locales \
    wget \
    tar \
    language-pack-ja-base language-pack-ja locales &&\
    wget https://julialang-s3.julialang.org/bin/linux/x64/1.7/julia-1.7.0-linux-x86_64.tar.gz &&\
    tar zxvf julia-1.7.0-linux-x86_64.tar.gz -C /usr --strip-components 1 &&\
    rm julia-1.7.0-linux-x86_64.tar.gz &&\
    echo "alias newalias='julia'" >> ~/.bashrc &&\
    source ~/.bashrc &&\
    mkdir /root/${dir} &&\
    locale-gen ${lang}

#~~~~~~~~~~~~~~~~~~~~~~ EDIT ~~~~~~~~~~~~~~~~~~~~~~~#

ENV LANG ${lang}
ENV LANGUAGE ${lang}
ENV LC_ALL ${lang}
ENV TZ=Asia/Tokyo
ENV TZ JST-9

EXPOSE 22
