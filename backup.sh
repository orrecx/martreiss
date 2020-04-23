#!/bin/bash
scp -r \
Dockerfile \
build_with_docker.sh \
backup.sh \
common \
1_done_on_hostsystem \
2_run_by_user_lfs \
3_run_by_root \
with_docker \
with_docker_final \
orex@192.168.0.17:~/workspace/linuxfromscratch
