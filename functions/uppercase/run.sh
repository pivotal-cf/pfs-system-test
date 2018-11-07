#!/bin/bash

source ../helpers.sh

dir=`dirname "${BASH_SOURCE[0]}"`
function=`basename $dir`

for invoker in command jar java java-local node; do
  path="$dir/$invoker"
  function_name="fats-$function-$invoker"
  image="${USER_ACCOUNT}/${function_name}:${CLUSTER_NAME}"
  input_data="hello"
  expected_data="HELLO"

  run_function $path $invoker $function_name $image $input_data $expected_data
done
