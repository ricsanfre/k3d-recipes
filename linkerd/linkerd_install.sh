#!/bin/bash

linkerd install | kubectl apply -f -

linkerd viz install --set dashboard.enforcedHostRegexp=.* | kubectl apply -f -

linkerd viz dashboard --address 0.0.0.0 &
