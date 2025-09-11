#!/bin/bash
i=0
status=1
while [ $status -eq 1 ] && [ $i -lt 10 ]  
do
  status=$(oc get WebSphereLibertyApplication modresorts -o jsonpath='{.status.conditions[*]}' | tr '}' '\12' |grep \"Ready\" | tr ',' '\12' |grep status | grep False |wc -l )
  sleep 10
  echo -n .
  i=$(expr $i + 1)
done
exit $status
