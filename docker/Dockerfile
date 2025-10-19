FROM ubuntu:24.04
RUN apt update && apt upgrade -y

# Required development software
RUN apt-get install -y --no-install-recommends openssh-server wget unzip file cmake make gawk gcc git curl tcsh binutils ca-certificates \
            libjansson4 libconfig-dev libelf-dev libicu-dev libncurses-dev libreadline-dev libjansson-dev libssl-dev \
            libcurl4-openssl-dev xz-utils vim

# Install YottaDB from source
ENV ydb_distrib="https://gitlab.com/api/v4/projects/7957109/repository/tags"
ENV ydb_tmpdir='tmpdir'
RUN mkdir $ydb_tmpdir && \
    wget -P $ydb_tmpdir ${ydb_distrib} 2>&1 1>${ydb_tmpdir}/wget_latest.log && \
    ydb_version=`sed 's/,/\n/g' ${ydb_tmpdir}/tags | grep -E "tag_name|.pro.tgz" | grep -B 1 ".pro.tgz" | grep "tag_name" | sort -r | head -1 | cut -d'"' -f6` && \
    git clone --depth 1 --branch $ydb_version https://gitlab.com/YottaDB/DB/YDB.git && \
    cd YDB && \
    mkdir build && cd build && \
    cmake .. && \
    make -j 2 && \
    make install && \
    cd yottadb_r* && \
    ./ydbinstall --gui --utf8

# Set environment variables
ENV LD_LIBRARY_PATH="/usr/local/lib/yottadb/r202/"
ENV PATH="/root/.local/share/grabnim/current/bin:/root/.nimble/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Install the Nim installer
RUN wget https://codeberg.org/janAkali/grabnim/raw/branch/master/misc/install.sh && sh install.sh

# install the nim environment
RUN grabnim && \
    nimble install nimlangserver && \
    nimble install bingo && \
    nimble install malebolgia

# Clone the nim-yottadb repo
RUN git clone https://github.com/ljoeckel/nim-yottadb.git

# cleanup
RUN rm -rf YDB

# update .bashrc
RUN echo 'export PATH="/root/.local/share/grabnim/current/bin:$PATH"' >> /root/.bashrc && \
    echo 'export PATH="/root/.nimble/bin:$PATH"' >> /root/.bashrc && \
    echo '. /usr/local/lib/yottadb/r202/ydb_env_set' >> /root/.bashrc && \
    echo 'LD_LIBRARY_PATH="/usr/local/lib/yottadb/r202/"' >> /root/.bashrc
    
#    echo 'export ydb_ci=/root/.yottadb/r2.02_x86_64/r/callm.ci' >> /root/.bashrc
# ENV T="/root/.yottadb/r2.02_x86_64/r/"
# ENV TF=${T}/callm.ci
# RUN mkdir -p ${T} && \
#     echo "method1  : void method1^callm()" >> ${TF} && \
#     echo "method2  : void method2^callm()" >>  ${TF}
# ENV TF=${T}/callm.m
# RUN echo 'callm   ;' >>  ${TF} && \
#     echo '    quit' >>  ${TF} && \
#     echo 'method1 ; Echo back VAR1 set by Nim program' >>  ${TF} && \
#     echo '    set RESULT=VAR1' >>  ${TF} && \
#     echo '    quit' >>  ${TF} && \
#     echo 'method2 ; make something with VAR1 set by Nim program' >>  ${TF} && \
#     echo '    write VAR1' >>  ${TF} && \
#     echo '    set RESULT="TheResultFrom YDB"' >>  ${TF} && \
#     echo '    quit' >>  ${TF}

CMD ["bash", "-l"]