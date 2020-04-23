#FROM ubuntu:eoan as mini_lfs
#RUN mkdir -pv /lfs/results
#WORKDIR /lfs
#COPY with_docker ./
#CMD ["/lfs/main.sh"]

FROM ubuntu:eoan as final_build
RUN mkdir -pv /lfs/results
WORKDIR /lfs
#COPY --from=mini_lfs /lfs/tools .
#COPY --from=mini_lfs /lfs/sources .
COPY tmp/sources ./sources/
COPY tmp/tools ./tools/
COPY with_docker_final ./
RUN chmod +x /lfs/tools/bin/ls
#RUN cd / && rm -rf $(/lfs/tools/bin/ls -1 / | /lfs/tools/bin/grep -v lfs )
RUN export LFS="/lfs"
CMD ["/lfs/tools/bin/bash", "-c", "/lfs/main.sh"]