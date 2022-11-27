#!/bin/bash

function verify {
    until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 60 ]; do
        $ROLLOUT_STATUS_CMD
        ATTEMPTS=$((attempts + 1))
        sleep 1
    done
}

kubectl apply -f starter/apps/canary/canary-v2.yml
kubectl apply -f starter/apps/canary/canary-svc.yml

# Get number of pods
canaryV1=$(kubectl get pods -n udacity | grep -c canary-v1)
canaryV2=$(kubectl get pods -n udacity | grep -c canary-v2)

# equivalent to 100%
numberOfReplV1=$(kubectl get pods -n udacity | grep -c canary-v1)

# Get floor of number of pod
expectedNumber=$(($numberOfReplV1 / 2))

# Increase canary deployment
x=0
while [ $x -le $expectedNumber ]
do
    kubectl scale deployment canary-v2 --replicas=$((canaryV2 + $x)) -n udacity
    kubectl scale deployment canary-v1 --replicas=$((canaryV1 - $x)) -n udacity
    sleep 10
    x=$(( $x + 1 ))
done

