#!/bin/bash

SERVICE_DOMAIN=$(cat ~/.service-domain)

while ! curl -sSLI https://$SERVICE_DOMAIN/about | head -n1 | grep "200"; do
  sleep 1s
done

