#!/bin/bash
i=0
while [ $(oc get WebSphereLibertyApplication modresorts -o jsonpath='{.status.conditions[*]}' | jq '. | select(.type == "Ready") | .status' | grep True |wc -l ) -eq 0 || i -lt 10 )  ]
  sleep 10
  echo -n .
  i=$(expr $i + 1)
done
