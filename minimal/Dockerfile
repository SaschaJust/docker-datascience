FROM ubuntu:bionic

MAINTAINER Sascha Just <sascha.just@own-hero.net>

ARG JUPYTER_TOKEN=84a471ab58d5dbe8c23455b5b6a92f143cc871b1674a5457d83cbb377d06b18c
ARG NB_USER="datascience"

USER root

ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    NB_USER=$NB_USER \
    NB_UID=1000 \
    NB_GID=100 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$NB_USER \
    DEBIAN_FRONTEND=noninteractive

RUN set -xe \
    && apt-get update \
    && apt-get install -yq --no-install-recommends \
      wget \
      bzip2 \
      ca-certificates \
      sudo \
      locales \
      fonts-liberation \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen

WORKDIR /tmp

# install FiraSans, FiraMono, and FiraCode
RUN set -xe \
    && wget --quiet https://github.com/bBoxType/FiraSans/archive/master.tar.gz \
    && tar xzf master.tar.gz \
    && mkdir -p /usr/share/fonts/opentype/fira \
    && mkdir -p /usr/share/fonts/truetype/fira \
    && mkdir -p /usr/share/fonts/woff/fira \
    && find FiraSans-master/ -name "*.otf" -exec cp {} /usr/share/fonts/opentype/fira/ \; \
    && find FiraSans-master/ -name "*.ttf" -exec cp {} /usr/share/fonts/truetype/fira/ \; \
    && find FiraSans-master/ -name "*.woff" -exec cp {} /usr/share/fonts/woff/fira/ \; \
    && rm -rf FiraSans-master master.tar.gz

RUN groupadd wheel -g 11 && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    mkdir -p $CONDA_DIR && \
    chown $NB_USER:$NB_GID $CONDA_DIR && \
    chmod g+w /etc/passwd

USER $NB_UID

WORKDIR /home/$NB_USER

RUN mkdir /home/$NB_USER/work

ENV MINICONDA_VERSION 4.5.4
RUN cd /tmp && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "a946ea1d0c4a642ddf0c3a26a18bb16d *Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c - && \
    /bin/bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    # https://github.com/jupyter/docker-stacks/pull/499 \
    # https://github.com/jupyter/docker-stacks/issues/497 \
    $CONDA_DIR/bin/conda config --system --append channels r && \
    $CONDA_DIR/bin/conda config --system --prepend channels conda-forge && \
    $CONDA_DIR/bin/conda config --system --set auto_update_conda false && \
    $CONDA_DIR/bin/conda config --system --set show_channel_urls true && \
    $CONDA_DIR/bin/conda install --quiet --yes conda="${MINICONDA_VERSION%.*}.*" && \
    $CONDA_DIR/bin/conda update --all --quiet --yes && \
    conda clean -tipsy && \
    rm -rf /home/$NB_USER/.cache/yarn

# Install Tini
RUN conda install --quiet --yes 'tini=0.18.0' \
    && conda list tini | grep tini | tr -s ' ' | cut -d ' ' -f 1,2 >> $CONDA_DIR/conda-meta/pinned \
    && conda clean -tipsy

RUN set -xe \
    && conda install --quiet --yes \
    'notebook=5.6.*' \
    'jupyterhub=0.9.*' \
    'jupyterlab=0.34.*' \
    'jupyter_nbextensions_configurator=0.4*' \
    'jupyter_contrib_nbextensions=0.5*' \
    && wget --quiet https://github.com/SaschaJust/jupyter-themes/archive/master.tar.gz \
    && tar xzf master.tar.gz \
    && cd jupyter-themes-master \
    && python setup.py install \
    && cd .. \
    && rm -rf jupyter-themes \
    && conda clean -tipsy \
    && jupyter labextension install @jupyterlab/hub-extension \
    && jupyter notebook --generate-config \
    && rm -rf $CONDA_DIR/share/jupyter/lab/staging \
    && rm -rf /home/$NB_USER/.cache/yarn

# fix autocompletion
RUN set -xe \
    && echo 'c.Completer.use_jedi = True' >>/opt/conda/lib/python3.6/site-packages/jupyter_core/tests/dotipython/profile_default/ipython_config.py

# install jupyter notebook extensions
RUN jupyter contrib nbextension install --user && jupyter nbextensions_configurator enable --user
# set jupyter theme
RUN jt -t monokai -altp -altmd -fs 13 -tfs 13 -nfs 13 -ofs 10 -cellw 90% -T -nf firasans -f firacode

# Make port 8888 available to the world outside this containerENTRYPOINT ["tini", "-g", "--"]
ENTRYPOINT ["tini", "-g", "--"]
EXPOSE 8888
CMD jupyter lab --ip=* --port=8888 --no-browser --notebook-dir=/home/$NB_USER --allow-root --NotebookApp.token=${JUPYTER_TOKEN}
