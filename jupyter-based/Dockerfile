ARG JUPYTER_TOKEN=84a471ab58d5dbe8c23455b5b6a92f143cc871b1674a5457d83cbb377d06b18c
FROM jupyter/scipy-notebook

MAINTAINER Sascha Just <sascha.just@own-hero.net>

USER root

# R pre-requisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fonts-dejavu \
    fonts-firacode \
    tzdata \
    gfortran \
    gnupg2 \
    gcc \
    hdf5-tools

# Julia dependencies
# install Julia packages in /opt/julia instead of $HOME
ENV JULIA_PKGDIR=/opt/julia
ENV JULIA_VERSION=1.0.0
ENV JULIA_CHECKSUM=bea4570d7358016d8ed29d2c15787dbefaea3e746c570763e7ad6040f17831f3

RUN mkdir /opt/julia-${JULIA_VERSION} && \
    cd /tmp && \
    wget -q https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz && \
    echo "${JULIA_CHECKSUM} *julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | sha256sum -c - && \
    tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C /opt/julia-${JULIA_VERSION} --strip-components=1 && \
    rm /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz
RUN ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia

# Show Julia where conda libraries are \
RUN mkdir /etc/julia && \
    echo "push!(Libdl.DL_LOAD_PATH, \"$CONDA_DIR/lib\")" >> /etc/julia/juliarc.jl && \
    # Create JULIA_PKGDIR \
    mkdir $JULIA_PKGDIR && \
    chown $NB_USER $JULIA_PKGDIR && \
    fix-permissions $JULIA_PKGDIR

USER $NB_UID

RUN conda config --add channels r

RUN conda install --quiet --yes \
    'python>=3.6.6' \
    'rpy2>=2.9.4' \
    'r-base=3.4.1' \
    'r-irkernel>=0.8.12' \
    'r-plyr>=1.8.4' \
    'r-devtools>=1.13.6' \
    'r-tidyverse>=1.1.1' \
    'r-irkernel>=0.8.12' \
    'r-plyr>=1.8.4' \
    'r-devtools>=1.13.6' \
    'r-shiny>=1.0.5' \
    'r-rmarkdown>=1.9' \
    'r-forecast>=8.2' \
    'r-rsqlite>=2.0' \
    'r-reshape2>=1.4.3' \
    'r-nycflights13>=1.0.0' \
    'r-caret>=6.0_80' \
    'r-rcurl>=1.95_4.11' \
    'r-crayon>=1.3.4' \
    'r-randomforest>=4.6_12' \
    'r-htmltools>=0.3.6' \
    'r-sparklyr>=0.8.3' \
    'r-htmlwidgets>=1.0' \
    'r-hexbin>=1.27.2' \
    'tensorflow>=1.9.0' \
    'keras>=2.2.2' \
    'jupyterthemes>=0.19.6' \
    'plotly>=3.1.1' \
    'imbalanced-learn>=0.3.3' \
    'psycopg2>=2.7.5' \
    'tabulate>=0.8.2' \
    'ipywidgets>=7.4.0' \
    'jupyter_nbextensions_configurator=0.4*' \
    'jupyter_contrib_nbextensions=0.5*' && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

RUN jupyter contrib nbextension install --user && jupyter nbextensions_configurator enable --user

RUN jt -t grade3 -altp -altmd -fs 13 -tfs 13 -nfs 13 -ofs 10 -cellw 90% -T -nf opensans -f firacode

# Add Julia packages. Only add HDF5 if this is not a test-only build since
# it takes roughly half the entire build time of all of the images on Travis
# to add this one package and often causes Travis to timeout.
#
# Install IJulia as jovyan and then move the kernelspec out
# to the system share location. Avoids problems with runtime UID change not
# taking effect properly on the .local folder in the jovyan home dir.
COPY install-packages.jl /tmp/
RUN julia --color=yes /tmp/install-packages.jl && \
    # move kernelspec out of home \
    mv $HOME/.local/share/jupyter/kernels/julia* $CONDA_DIR/share/jupyter/kernels/ && \
    chmod -R go+rx $CONDA_DIR/share/jupyter && \
    rm -rf $HOME/.local && \
    fix-permissions $JULIA_PKGDIR $CONDA_DIR/share/jupyter


### ELIXIR INSTALLATION
# Install build d3dependencies for erlang/elixir/rebar
USER root

RUN apt-get install -y --no-install-recommends \
    autoconf \
    dpkg-dev \
    g++ \
    gcc \
    libcurl4-openssl-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libssl-dev \
    libxslt-dev \
    make

# Install Erlang
ENV OTP_VERSION="21.0.4"

ENV OTP_DOWNLOAD_URL="https://github.com/erlang/otp/archive/OTP-${OTP_VERSION}.tar.gz" \
    OTP_DOWNLOAD_SHA256="8830c81042835070d72130a0df78058a5ccb8db9f93829310d93ed6e2e323e0d"

RUN set -xe \
	&& runtimeDeps='libodbc1 \
			libsctp1 \
			libwxgtk3.0' \
	&& buildDeps='unixodbc-dev \
			libsctp-dev \
			libwxgtk3.0-dev' \
	# && apt-get update \
	&& apt-get install -y --no-install-recommends $runtimeDeps \
	&& apt-get install -y --no-install-recommends $buildDeps \
    && apt-get install -y curl autoconf dpkg-dev \
	&& curl -fSL -o otp-src.tar.gz "$OTP_DOWNLOAD_URL" \
	&& echo "$OTP_DOWNLOAD_SHA256  otp-src.tar.gz" | sha256sum -c - \
	&& export ERL_TOP="/usr/src/otp_src_${OTP_VERSION%%@*}" \
	&& mkdir -vp $ERL_TOP \
	&& tar -xzf otp-src.tar.gz -C $ERL_TOP --strip-components=1 \
	&& rm otp-src.tar.gz \
	&& ( cd $ERL_TOP \
	  && ./otp_build autoconf \
	  && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	  && ./configure --build="$gnuArch" \
	  && make -j$(nproc) \
	  && make install ) \
	&& find /usr/local -name examples | xargs rm -rf \
	&& apt-get purge -y --auto-remove $buildDeps \
	&& rm -rf $ERL_TOP /var/lib/apt/lists/*

ENV REBAR_VERSION="2.6.4"

ENV REBAR_DOWNLOAD_URL="https://github.com/rebar/rebar/archive/${REBAR_VERSION}.tar.gz" \
    REBAR_DOWNLOAD_SHA256="577246bafa2eb2b2c3f1d0c157408650446884555bf87901508ce71d5cc0bd07"

RUN set -xe \
	&& mkdir -p /usr/src/rebar-src \
	&& curl -fSL -o rebar-src.tar.gz "$REBAR_DOWNLOAD_URL" \
	&& echo "$REBAR_DOWNLOAD_SHA256 rebar-src.tar.gz" | sha256sum -c - \
	&& tar -xzf rebar-src.tar.gz -C /usr/src/rebar-src --strip-components=1 \
	&& rm rebar-src.tar.gz \
	&& cd /usr/src/rebar-src \
	&& ./bootstrap \
	&& install -v ./rebar /usr/local/bin/ \
	&& rm -rf /usr/src/rebar-src

# Install Rebar to build ielixir
ENV REBAR3_VERSION="3.6.1"

ENV REBAR3_DOWNLOAD_URL="https://github.com/erlang/rebar3/archive/${REBAR3_VERSION}.tar.gz" \
    REBAR3_DOWNLOAD_SHA256="40b3c85440f3235c7b149578d0211bdf57d1c66390f888bb771704f8abc71033"

RUN set -xe \
	&& mkdir -p /usr/src/rebar3-src \
	&& curl -fSL -o rebar3-src.tar.gz "$REBAR3_DOWNLOAD_URL" \
	&& echo "$REBAR3_DOWNLOAD_SHA256 rebar3-src.tar.gz" | sha256sum -c - \
	&& tar -xzf rebar3-src.tar.gz -C /usr/src/rebar3-src --strip-components=1 \
	&& rm rebar3-src.tar.gz \
	&& cd /usr/src/rebar3-src \
	&& HOME=$PWD ./bootstrap \
	&& install -v ./rebar3 /usr/local/bin/ \
	&& rm -rf /usr/src/rebar3-src

# Install Elixir
# Project on GitHub: https://github.com/elixir-lang/elixir
ENV ELIXIR_VERSION="v1.7.2"
ENV ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/${ELIXIR_VERSION}.tar.gz" \
    ELIXIR_DOWNLOAD_SHA256="3258eca6b5caa5e98b67dd033f9eb1b0b7ecbdb7b0f07c111b704700962e64cc" \
	LANG=C.UTF-8

RUN set -xe \
	&& curl -fSL -o elixir-src.tar.gz $ELIXIR_DOWNLOAD_URL \
	&& echo "$ELIXIR_DOWNLOAD_SHA256  elixir-src.tar.gz" | sha256sum -c - \
	&& mkdir -p /usr/local/src/elixir \
	&& tar -xzC /usr/local/src/elixir --strip-components=1 -f elixir-src.tar.gz \
	&& rm elixir-src.tar.gz \
	&& cd /usr/local/src/elixir \
	&& make install clean

ENV IELIXIR_VERSION=0.9.13
ENV IELIXIR_CHECKSUM=c466958c19b8f64ed80fe544196fab0dba3279da23c5bf775460ce13067a0626 \
    IELIXIR_DOWNLOAD_URL=https://github.com/pprzetacznik/IElixir/archive/${IELIXIR_VERSION}.tar.gz

# Install IElixir kernel
RUN set -xe && \
    mkdir -p /opt/ielixir-${IELIXIR_VERSION} && \
    cd /tmp && \
    curl -fSL -o ielixir-${IELIXIR_VERSION}.tar.gz ${IELIXIR_DOWNLOAD_URL} && \
    echo "${IELIXIR_CHECKSUM} *ielixir-${IELIXIR_VERSION}.tar.gz" | sha256sum -c - && \
    tar xzf ielixir-${IELIXIR_VERSION}.tar.gz -C /opt/ielixir-${IELIXIR_VERSION} --strip-components=1 && \
    rm /tmp/ielixir-${IELIXIR_VERSION}.tar.gz && \
    cd /opt/ielixir-${IELIXIR_VERSION} && \
    sed -i -e 's#^ *elixir: ".*#     elixir: ">= 1.1.0",#g' mix.exs && \
    sed -i -e "s#^ *\"display_name\": \".*#   \"display_name\": \"Elixir ${ELIXIR_VERSION}\",#g" install_script.sh && \
    mix local.hex --force && \
    mix deps.get && \
    mix local.rebar --forcea && \
    mix deps.compile && \
    ./install_script.sh \
    chown $NB_USER /opt/ielixir-${IELIXIR_VERSION} && \
    fix-permissions /opt/ielixir-${IELIXIR_VERSION}

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID
