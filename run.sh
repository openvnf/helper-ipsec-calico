#!/bin/sh
set -euo pipefail

_lookupserviceendpoing () {
    KUBE_TOKEN=$(</var/run/secrets/kubernetes.io/serviceaccount/token)
    IP=`curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
          https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/${1}/endpoints/${2} \
          | jq .subsets[0].addresses[0].ip`
    if [ "$IP" != "null" ]
    then
        echo $IP
        return 0
    else
        return 2
    fi
}

_remove_route() {
    echo "ip route del $IPSEC_REMOTENET via $serviceip"
    ip route del $IPSEC_REMOTENET via $serviceip
    return 0
}

_add_route() {
    echo "======= setup route ======="
    echo "ip route add $IPSEC_REMOTENET via $1"
    ip route add $IPSEC_REMOTENET via $1
}

_term() {
    echo "======= caught SIGTERM signal ======="
    _remove_route
    exit 0
}


echo "IPSEC service is ${IPSEC_SERVICE}"
for i in 1 2 3 4 5
do
    sleep 10
    set +e
    serviceip=`_lookupserviceendpoing ${IPSEC_NAMESPACE} ${IPSEC_SERVICE}`
    if [ $? -eq 2 ]; then
      echo "service endpoint could not be looked up, try again"   
      continue 
    else
      set -e
      echo "IP of IPSEC service endpoint is ${serviceip}"
      trap _term TERM INT
      _add_route ${serviceip}
      while true
      do
        echo "going to sleep for 1d"
        sleep 1d
      done
    fi
done
set -e
echo "service endpoint could finally not be found"
exit 1

