ARG baseimage="ubuntu:eoan"
FROM ${baseimage} as mini_sys
ENV WRK="/workspace" LFS="/lfs" DOCKER_CONTEXT=1
RUN mkdir -pv ${LFS}/results ${WRK}
COPY 1_prepare_build_env ${WRK}/1_prepare_build_env
COPY 2_tmp_sys ${WRK}/2_tmp_sys
COPY common ${WRK}/common
COPY components ${WRK}/components
COPY build_in_container ${WRK}/build_in_container
COPY backyard ${WRK}/backyard
WORKDIR ${WRK}
#RUN ./build_in_container/1_build_tmp_sys.sh
CMD [ "./build_in_container/1_build_tmp_sys.sh" ]

#FROM scratch as basic_sys
#ENV LFS="/lfs"
#COPY --from=mini_sys ${LFS}/tools /tools
#COPY --from=mini_sys ${LFS}/sources /sources
#COPY --from=mini_sys ${LFS}/tools/bin/bash /bin/sh
#COPY --from=mini_sys ${LFS}/tools/bin/bash /bin/bash
#ENV PATH="/tools/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" WRK="/workspace" LFS=""
#
#COPY 3_build_final_sys/vfs_scripts ${WRK}/vfs_scripts
#COPY common/utils.sh ${WRK}/vfs_scripts/utils.sh
#COPY 3_build_final_sys/vfs_config_scripts ${WRK}/vfs_config_scripts
#COPY common/utils.sh ${WRK}/vfs_config_scripts/utils.sh
#
#COPY 3_build_final_sys/kernel_build_config ${WRK}/vfs_config_scripts/kernel_build_config
#COPY 3_build_final_sys/bashrc ${WRK}/vfs_config_scripts/bashrc
#COPY 3_build_final_sys/profile ${WRK}/vfs_config_scripts/profile
#
#COPY build_in_container/2_main_basic_sys.sh ${WRK}/2_main_basic_sys.sh
#COPY 3_build_final_sys/main.sh ${WRK}/main.sh
#COPY 3_build_final_sys/1_create_virtual_fs.sh  ${WRK}/1_create_virtual_fs.sh
#RUN mkdir -pv /lfs/results
#
#WORKDIR ${WRK}
#CMD [ "./2_build_basic_sys.sh" ]
