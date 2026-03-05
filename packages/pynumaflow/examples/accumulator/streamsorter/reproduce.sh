#!/bin/bash
export LANG=C LC_ALL=C
set -Cxueo pipefail

ensure_ready() {
    local vertex_name="$1"
    kubectl wait --timeout 60s --for condition=Ready -l "numaflow.numaproj.io/vertex-name=${vertex_name}" pod
    screen -d -m -L -Logfile "${vertex_name}-numa.log" -- kubectl logs -f -l "numaflow.numaproj.io/vertex-name=${vertex_name}" -c numa
    screen -d -m -L -Logfile "${vertex_name}-udf.log" -- kubectl logs -f -l "numaflow.numaproj.io/vertex-name=${vertex_name}" -c udf
}

main() {
    kubectl apply -f pipeline.yaml
    sleep 1
    ensure_ready py-sink
    ensure_ready py-accum
    ensure_ready input-one
    ensure_ready input-two
    watch -n 1 'date | tee -a watch.log ; kubectl get pod | tee -a watch.log'
    kubectl delete -f pipeline.yaml
}

main "$@"
