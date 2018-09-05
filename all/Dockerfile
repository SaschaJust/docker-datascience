FROM nicbet/datascience-base

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
RUN pip3 install numpy pandas matplotlib seaborn scipy statsmodels plotly bokeh pydot scikit-learn tensorflow keras nltk spacy scrapy theano networkx opencv-python opencv-contrib-python xgboost shap graphviz \
 && pip3 install pymc3 \
 && pip3 install http://download.pytorch.org/whl/cpu/torch-0.4.1-cp36-cp36m-linux_x86_64.whl \
 && pip3 install torchvision

# IRkernel and R libraries
USER root
WORKDIR /tmp
RUN echo 'install.packages("devtools")' | R --no-save \
 && echo 'devtools::install_github("IRkernel/IRkernel")' | R --no-save \
 && echo 'IRkernel::installspec(user = FALSE)' | R --no-save \
 && echo 'install.packages("rstan", repos = "https://cloud.r-project.org/", dependencies=TRUE)' | R --no-save \
 && echo 'install.packages(c("coda","mvtnorm","devtools","loo"))' | R --no-save \
 && echo 'library(devtools)\ndevtools::install_github("rmcelreath/rethinking")' | R --no-save

# IRuby kernel and Ruby gems
USER root
WORKDIR /tmp
RUN apt install -y libtool libtool-bin libffi-dev libczmq-dev libzmq3-dev autoconf pkg-config
RUN gem install cztop iruby rbczmq -- --with-system-libs

USER $NB_USER
WORKDIR $HOME
RUN iruby register --force

# TODO: IElixir kernel and hex packages

# TODO: Julia kernel and julia packages

# New Entrypoint
USER $NB_USER
WORKDIR $HOME
CMD ["/home/datascience/jupyter-server.sh"]
