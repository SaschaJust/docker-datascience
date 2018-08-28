FROM ubuntu:18.04

# For apt install
ENV DEBIAN_FRONTEND noninteractive

#______________________________________________________________________________________________________
# Versions
ENV GO_VERSION=1.11
ENV ELIXIR_VERSION=1.7.2-1
ENV PYTHON_VERSION=3.6.6
ENV R_VERSION=3.5.1
ENV RUBY_VERSION=2.5.1
ENV JULIA_VERSION=1.0.0

#______________________________________________________________________________________________________
# Add a Non-Privileged User
ENV NB_USER=datascience \
    NB_UID=1000 \
    NB_GID=100

ENV HOME=/home/$NB_USER

#______________________________________________________________________________________________________
# Base packages and system-wide dependencies
RUN apt-get update \
 && apt-get install -y apt-utils \
 && apt-get install -y wget git bzip2 sudo locales gnupg software-properties-common

#______________________________________________________________________________________________________
# Set the locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

#______________________________________________________________________________________________________
# Create jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
USER root
WORKDIR /root
ADD fix-permissions /usr/local/bin/fix-permissions
RUN groupadd wheel -g 11 && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    chmod g+w /etc/passwd && \
    fix-permissions $HOME


#______________________________________________________________________________________________________
# Install GO Language
# https://golang.org/doc/install
USER root
WORKDIR /tmp
RUN wget -q https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz \
 && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
 && echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/profile.d/go.sh \
 && rm -rf go${GO_VERSION}.linux-amd64.tar.gz


#______________________________________________________________________________________________________
# Install Elixir Language
# https://elixir-lang.org/install.html
USER root
WORKDIR /tmp
RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb \
 && dpkg -i erlang-solutions_1.0_all.deb \
 && apt-get update \
 && apt-get install -y esl-erlang \
 && apt-get install -y elixir=${ELIXIR_VERSION} \
 && apt-mark hold elixir \
 && rm -rf lang-solutions_1.0_all.deb

#______________________________________________________________________________________________________
# Hex Package Manager and rebar3
# https://github.com/erlang/rebar3#getting-started
USER $NB_UID
WORKDIR $HOME
RUN wget -q https://s3.amazonaws.com/rebar3/rebar3 \
 && chmod +x rebar3 \
 && ./rebar3 local install \
 && echo 'export PATH=$PATH:/home/datascience/.cache/rebar3/bin' >> .bashrc \
 && rm -rf rebar3 \
 && mix local.hex --force


#______________________________________________________________________________________________________
# Julia Language
# https://julialang.org/downloads/platform.html
USER root
WORKDIR /tmp
RUN wget -q https://julialang-s3.julialang.org/bin/linux/x64/1.0/julia-1.0.0-linux-x86_64.tar.gz \
 && tar -C /usr/local -xzf julia-1.0.0-linux-x86_64.tar.gz \
 && echo 'export PATH=$PATH:/usr/local/julia-1.0.0/bin' >> /etc/profile.d/julia.sh \
 && rm -rf julia-1.0.0-linux-x86_64.tar.gz


#______________________________________________________________________________________________________
# Install R language
# https://www.digitalocean.com/community/tutorials/how-to-install-r-on-ubuntu-18-04
USER root
WORKDIR /tmp
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
 && add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/' \
 && apt update \
 && apt install -y r-base=${R_VERSION}-1bionic \
 && apt-mark hold r-base


#______________________________________________________________________________________________________
# Node 8.x LTS
# https://gorails.com/setup/ubuntu/18.04
USER root
WORKDIR /tmp
RUN apt install -y curl \
 && curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - \
 && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update \
 && apt-get install -y git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev nodejs yarn


#______________________________________________________________________________________________________
# Ruby
# https://gorails.com/setup/ubuntu/18.04
USER root
WORKDIR /tmp
RUN wget -q http://ftp.ruby-lang.org/pub/ruby/2.5/ruby-2.5.1.tar.gz \
 && tar -xzvf ruby-2.5.1.tar.gz \
 && cd ruby-2.5.1/ \
 && ./configure \
 && make \
 && make install \
 && ruby -v \
 && gem install bundler \
 && rm -rf /tmp/ruby-2.5.1.tar.gz \
 && rm -rf /tmp/ruby-2.5.1


#______________________________________________________________________________________________________
# Python 3
USER root
WORKDIR /tmp
RUN apt install -y python3 \
 && apt install -y python3-pip \
 && pip3 install virtualenv virtualenvwrapper


#______________________________________________________________________________________________________
# Entrypoint
USER $NB_UID
WORKDIR $HOME
CMD ["/bin/bash", "--login"]

