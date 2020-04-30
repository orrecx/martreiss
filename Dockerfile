FROM ubuntu:eoan as mini_sys
RUN mkdir -pv /lfs/results /workspace
COPY 1_prepare_build_env /workspace/1_prepare_build_env
COPY 2_build_mini_sys /workspace/2_build_mini_sys
COPY common /workspace/common
COPY build_on_docker /workspace/build_on_docker
ENV LFS="/lfs"
WORKDIR /workspace
RUN ./build_on_docker/1_main_mini_sys.sh

FROM scratch as basic_sys
COPY --from=mini_sys /lfs/tools /tools
COPY --from=mini_sys /lfs/sources /sources
COPY --from=mini_sys /lfs/tools/bin/bash /bin/sh
COPY --from=mini_sys /lfs/tools/bin/bash /bin/bash
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/tools/bin" WRK="/workspace" LFS=""

COPY 3_build_final_sys/vfs_scripts /workspace/vfs_scripts
COPY common/utils.sh /workspace/vfs_scripts/utils.sh
COPY 3_build_final_sys/vfs_config_scripts /workspace/vfs_config_scripts
COPY common/utils.sh /workspace/vfs_config_scripts/utils.sh

COPY 3_build_final_sys/kernel_build_config /workspace/vfs_config_scripts/kernel_build_config
COPY 3_build_final_sys/bashrc /workspace/vfs_config_scripts/bashrc
COPY 3_build_final_sys/profile /workspace/vfs_config_scripts/profile

COPY build_on_docker/2_main_basic_sys.sh /workspace/2_main_basic_sys.sh
COPY 3_build_final_sys/main.sh /workspace/main.sh
COPY 3_build_final_sys/1_create_virtual_fs.sh  /workspace/1_create_virtual_fs.sh
RUN mkdir -pv /lfs/results

WORKDIR /workspace
CMD ["./2_main_basic_sys.sh"]
