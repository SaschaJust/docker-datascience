FROM nicbet/datascience-base

# Python libraries dependencies
USER root
WORKDIR /tmp
RUN apt install -y graphviz

# Python libraries
USER $NB_USER
WORKDIR $HOME

RUN pip3 install jupyterlab

RUN pip3 install numpy pandas matplotlib seaborn scipy statsmodels plotly bokeh pydot scikit-learn tensorflow keras nltk spacy scrapy theano networkx opencv-python opencv-contrib-python \
 && pip3 install http://download.pytorch.org/whl/cpu/torch-0.4.1-cp36-cp36m-linux_x86_64.whl \
 && pip3 install torchvision
