FROM ubuntu:eoan as mini_sys
RUN mkdir -pv /lfs /workspace
COPY 1_prepare_build_env /workspace/1_prepare_build_env
COPY 2_build_mini_sys /workspace/2_build_mini_sys
COPY common /workspace/common
COPY build_on_docker /workspace/build_on_docker
ENV LFS="/lfs"
WORKDIR /workspace
CMD ["./build_on_docker/main.sh"]

#FROM ubuntu:eoan as final_sys
#RUN mkdir -pv /lfs/results
#WORKDIR /lfs
#COPY --from=mini_sys /lfs/tools .
#COPY --from=mini_sys /lfs/sources .
#COPY tmp/sources ./sources/
#COPY tmp/tools ./tools/
#COPY with_docker_final ./
#RUN chmod +x /lfs/tools/bin/ls
#RUN cd / && rm -rf $(/lfs/tools/bin/ls -1 / | /lfs/tools/bin/grep -v lfs )
#RUN export LFS="/lfs"
#CMD ["/lfs/tools/bin/bash", "-c", "/lfs/main.sh"]
