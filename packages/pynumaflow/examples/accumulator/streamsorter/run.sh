#!/bin/bash
export LANG=C LC_ALL=C
set -Cxueo pipefail

forward_http_pod() {
  local vertex port health
  vertex="$1"
  port="$2"
  health="https://localhost:${port}/health"

  if curl -ksS --fail-with-body "${health}" ; then
    return 0
  fi

  local pod
  pod="$(kubectl get pod -l "numaflow.numaproj.io/vertex-name=${vertex}" -o name)"
  screen -d -m -- kubectl port-forward "${pod}" "${port}:8443"
  sleep 1
}

curl_post_text() {
  curl -k -s -S -X POST -H 'Content-Type: text/plain' "$@"
}

main() {
  kubectl apply -f pipeline.yaml
  kubectl wait --timeout 60s --for condition=Ready -l app.kubernetes.io/component=vertex pod
  kubectl get pod
  forward_http_pod http-one 8441
  forward_http_pod http-two 8442

  if [ ! -f 2m.txt ] ; then
    set +o pipefail
    base64 -w 0 </dev/urandom | head -c $((2*1024*1024)) >2m.txt
    set -o pipefail
  fi

  while : ; do
    curl_post_text -d @2m.txt https://localhost:8441/vertices/http-one &
    local pid1=$!
    curl_post_text -d @2m.txt https://localhost:8442/vertices/http-two &
    local pid2=$!
    wait "${pid1}"
    wait "${pid2}"
  done
}

main "$@"
exit 0
