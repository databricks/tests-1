#!/bin/bash
#
# Copyright (c) 2018 Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

source /etc/os-release || source /usr/lib/os-release
kubernetes_dir=$(dirname "$(readlink -f "$0")")
cidir="${kubernetes_dir}/../../.ci/"
source "${cidir}/lib.sh"

arch="$(uname -m)"

KATA_HYPERVISOR="${KATA_HYPERVISOR:-qemu}"

# Using trap to ensure the cleanup occurs when the script exists.
trap '${kubernetes_dir}/cleanup_env.sh' EXIT

K8S_TEST_UNION=("k8s-attach-handlers.bats" \
	"k8s-block-volume.bats" \
	"k8s-configmap.bats" \
	"k8s-copy-file.bats" \
	"k8s-cpu-ns.bats" \
	"k8s-credentials-secrets.bats" \
	"k8s-custom-dns.bats" \
	"k8s-empty-dirs.bats" \
	"k8s-env.bats" \
	"k8s-exec.bats" \
	"k8s-expose-ip.bats" \
	"k8s-job.bats" \
	"k8s-limit-range.bats" \
	"k8s-liveness-probes.bats" \
	"k8s-memory.bats" \
	"k8s-number-cpus.bats" \
	"k8s-oom.bats" \
	"k8s-optional-empty-configmap.bats" \
	"k8s-optional-empty-secret.bats" \
	"k8s-parallel.bats" \
	"k8s-pid-ns.bats" \
	"k8s-pod-quota.bats" \
	"k8s-port-forward.bats" \
	"k8s-projected-volume.bats" \
	"k8s-qos-pods.bats" \
	"k8s-replication.bats" \
	"k8s-scale-nginx.bats" \
	"k8s-sysctls.bats" \
	"k8s-security-context.bats" \
	"k8s-shared-volume.bats" \
	"k8s-volume.bats" \
	"k8s-nginx-connectivity.bats" \
	"k8s-hugepages.bats")

# we may need to skip a few test cases when running on non-x86_64 arch
if [ -f "${cidir}/${arch}/configuration_${arch}.yaml" ]; then
	config_file="${cidir}/${arch}/configuration_${arch}.yaml"
	arch_k8s_test_union=$(${cidir}/filter/filter_k8s_test.sh ${config_file} "${K8S_TEST_UNION[*]}")
	mapfile -d " " -t K8S_TEST_UNION <<< "${arch_k8s_test_union}"
fi

pushd "$kubernetes_dir"
./init.sh
for K8S_TEST_ENTRY in ${K8S_TEST_UNION[@]}
do
	bats "${K8S_TEST_ENTRY}"
done
popd
