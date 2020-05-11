ARG baseimage="ubuntu:eoan"

FROM ${baseimage} as tmp_sys
ENV WRK="/workspace" LFS="/lfs" DOCKER_CONTEXT=1
RUN mkdir -pv ${LFS}/results ${WRK}
COPY 1_prepare_build_env ${WRK}/1_prepare_build_env
COPY 2_tmp_sys ${WRK}/2_tmp_sys
COPY common ${WRK}/common
COPY components ${WRK}/components
COPY build_in_container/1_build_tmp_sys.sh ${WRK}/build_in_container/1_build_tmp_sys.sh
COPY backyard ${WRK}/backyard
WORKDIR ${WRK}

RUN ./build_in_container/1_build_tmp_sys.sh
#CMD [ "./build_in_container/1_build_tmp_sys.sh" ]


FROM scratch as basic_sys
ENV LFS="/lfs"
COPY --from=tmp_sys ${LFS}/tools /tools
COPY --from=tmp_sys ${LFS}/sources /sources
COPY --from=tmp_sys ${LFS}/tools/bin/bash /bin/sh
COPY --from=tmp_sys ${LFS}/tools/bin/bash /bin/bash
RUN mkdir -pv ${LFS}/results
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/tools/bin" WRK="/workspace" LFS=""

RUN mkdir -pv ${WRK}/build_in_container 
COPY 3_base_sys ${WRK}/3_base_sys
COPY 4_configure_basic_sys ${WRK}/4_configure_basic_sys
COPY common ${WRK}/common
COPY build_in_container/2_build_basic_sys.sh ${WRK}/build_in_container/2_build_basic_sys.sh
WORKDIR ${WRK}

CMD [ "./build_in_container/2_build_basic_sys.sh" ]
