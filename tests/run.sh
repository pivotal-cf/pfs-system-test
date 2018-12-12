#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

source `dirname "${BASH_SOURCE[0]}"`/../start.sh

# install riff
source `dirname "${BASH_SOURCE[0]}"`/../install.sh riff

riff system install $SYSTEM_INSTALL_FLAGS

# health checks
echo "Checking for ready pods"
wait_pod_selector_ready 'knative=ingressgateway' 'istio-system'
wait_pod_selector_ready 'app=controller' 'knative-serving'
wait_pod_selector_ready 'app=webhook' 'knative-serving'
wait_pod_selector_ready 'app=build-controller' 'knative-build'
wait_pod_selector_ready 'app=build-webhook' 'knative-build'
wait_pod_selector_ready 'app=eventing-controller' 'knative-eventing'
wait_pod_selector_ready 'app=webhook' 'knative-eventing'
wait_pod_selector_ready 'clusterBus=stub' 'knative-eventing'
echo "Checking for ready ingress"
wait_for_ingress_ready 'knative-ingressgateway' 'istio-system'

# setup namespace
kubectl create namespace $NAMESPACE
fats_create_push_credentials $NAMESPACE
riff namespace init $NAMESPACE $NAMESPACE_INIT_FLAGS

# run test functions
echo "Run functions"
source `dirname "${BASH_SOURCE[0]}"`/../functions/helpers.sh

# uppercase
for test in java java-boot java-local node npm command; do
  path=`dirname "${BASH_SOURCE[0]}"`/../functions/uppercase/${test}
  function_name=fats-uppercase-${test}
  image=${IMAGE_REPOSITORY_PREFIX}/fats-uppercase-${test}:${CLUSTER_NAME}
  input_data=riff
  expected_data=RIFF

  run_function $path $function_name $image $input_data $expected_data
done

# eventing
# TODO renbable eventing tests once riff has a release compatible with knative eventing 0.2
# source `dirname "${BASH_SOURCE[0]}"`/eventing.sh
