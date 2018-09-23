FROM nicbet/datascience-base

# Sync APT
USER root
WORKDIR /tmp
RUN apt update

# Prerequisites (libraries, tools, dependencies)
USER root
WORKDIR /tmp
RUN apt install -y graphviz libgit2-dev

# Jupyter
USER $NB_USER
WORKDIR $HOME
RUN pip3 install jupyterlab

# Scripts
USER root
ADD jupyter-server.sh /home/datascience/jupyter-server.sh
RUN chmod a+x /home/datascience/jupyter-server.sh

ADD install-r-pkg /home/datascience/install-r-pkg
RUN chmod a+x /home/datascience/install-r-pkg

# Python libraries
USER $NB_USER
WORKDIR $HOME

RUN pip3 install numpy
RUN pip3 install pandas
RUN pip3 install matplotlib
RUN pip3 install seaborn
RUN pip3 install scipy
RUN pip3 install statsmodels
RUN pip3 install plotly
RUN pip3 install bokeh
RUN pip3 install pydot
RUN pip3 install scikit-learn
RUN pip3 install tensorflow
RUN pip3 install keras
RUN pip3 install nltk
RUN pip3 install spacy
RUN pip3 install scrapy
RUN pip3 install theano
RUN pip3 install networkx
RUN pip3 install opencv-python
RUN pip3 install opencv-contrib-python
RUN pip3 install xgboost
RUN pip3 install shap
RUN pip3 install graphviz
RUN pip3 install pymc3
RUN pip3 install http://download.pytorch.org/whl/cpu/torch-0.4.1-cp36-cp36m-linux_x86_64.whl
RUN pip3 install torchvision

# IRkernel and R libraries
USER root
WORKDIR /tmp

RUN echo 'install.packages("devtools")' | R --no-save
RUN echo "install.packages(c('repr', 'IRdisplay', 'crayon', 'pbdZMQ'))" | R --no-save
RUN echo 'devtools::install_github("IRkernel/IRkernel")' | R --no-save
RUN echo 'IRkernel::installspec(user = FALSE)' | R --no-save
RUN echo 'install.packages("rstan", repos = "https://cloud.r-project.org/", dependencies=TRUE)' | R --no-save
RUN echo 'install.packages(c("coda","mvtnorm","devtools","loo"))' | R --no-save
RUN echo 'library(devtools)\ndevtools::install_github("rmcelreath/rethinking")' | R --no-save
RUN echo 'install.packages("rms", repos = "https://cloud.r-project.org/", dependencies=TRUE)' | R --no-save

# IRuby kernel and Ruby gems
USER root
WORKDIR /tmp
RUN apt install -y libtool libtool-bin libffi-dev libczmq-dev libzmq3-dev autoconf pkg-config
RUN gem install cztop iruby rbczmq -- --with-system-libs

USER $NB_USER
WORKDIR $HOME
RUN iruby register --force

# Julia kernel
USER $NB_USER
WORKDIR $HOME
COPY julia-kernel.jl .
RUN /usr/local/julia-1.0.0/bin/julia --color=yes julia-kernel.jl

# Julia packages
# USER root
# WORKDIR /tmp
# COPY julia-packages.jl .
# RUN /usr/local/julia-1.0.0/bin/julia --color=yes julia-packages.jl

# IElixir kernel and hex packages
USER root
WORKDIR /tmp
ENV REBAR_VERSION="2.6.4"

RUN set -xe \
	&& REBAR_DOWNLOAD_URL="https://github.com/rebar/rebar/archive/${REBAR_VERSION}.tar.gz" \
	&& REBAR_DOWNLOAD_SHA256="577246bafa2eb2b2c3f1d0c157408650446884555bf87901508ce71d5cc0bd07" \
	&& mkdir -p /usr/src/rebar-src \
	&& curl -fSL -o rebar-src.tar.gz "$REBAR_DOWNLOAD_URL" \
	&& echo "$REBAR_DOWNLOAD_SHA256 rebar-src.tar.gz" | sha256sum -c - \
	&& tar -xzf rebar-src.tar.gz -C /usr/src/rebar-src --strip-components=1 \
	&& rm rebar-src.tar.gz \
	&& cd /usr/src/rebar-src \
	&& ./bootstrap \
	&& install -v ./rebar /usr/local/bin/ \
	&& rm -rf /usr/src/rebar-src

USER $NB_USER
WORKDIR $HOME

RUN set -xe \
  && curl -s https://api.github.com/repos/pprzetacznik/IElixir/releases/latest | grep "tarball_url" | sed -n -e 's/.*tarball_url": "\(.*\)".*/\1/p' | xargs -t curl -fSL -o ielixir.tar.gz \
  && mkdir ielixir \
  && tar -zxvf ielixir.tar.gz -C ielixir --strip-components=1 \
  && rm ielixir.tar.gz \
  && cd ielixir \
	&& sed -i -e 's#^ *elixir: ".*#     elixir: ">= 1.1.0",#g' mix.exs \
  && sed -i -e "s#^ *\"display_name\": \".*#   \"display_name\": \"Elixir ${ELIXIR_VERSION}\",#g" install_script.sh \
  && ls -alh \
  && mix local.hex --force \
  && mix local.rebar --force \
  && mix deps.get \
  && mix deps.compile \
  && ./install_script.sh

# New Entrypoint
USER $NB_USER
WORKDIR $HOME
CMD ["/home/datascience/jupyter-server.sh"]
