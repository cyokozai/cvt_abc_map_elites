#!/bin/bash
for FUNCTION in sphere rastrigin rosenbrock griewank
do
    for METHOD in default abc
    do
        docker compose -f "./docker-compose.yaml" up -d --build julia-run
    done
done
