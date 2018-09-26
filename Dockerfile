# VERSION 1.10.0-2
# AUTHOR: Matthieu "Puckel_" Roisil
# DESCRIPTION: Basic Airflow container
# BUILD: docker build --rm -t puckel/docker-airflow .
# SOURCE: https://github.com/puckel/docker-airflow

FROM python:3.6-slim
LABEL maintainer="Puckel_"

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Airflow
ARG AIRFLOW_VERSION=1.10.0
ARG AIRFLOW_HOME=/usr/local/airflow
ENV AIRFLOW_GPL_UNIDECODE yes

# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8
ENV PYTHONPATH=:/usr/local/airflow/dags:/usr/local/airflow/config

RUN set -ex \
    && buildDeps=' \
        python3-dev \
        libkrb5-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        libblas-dev \
        liblapack-dev \
        libpq-dev \
        git \
    ' \
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -yqq --no-install-recommends \
        $buildDeps \
        build-essential \
        python3-pip \
        python3-requests \
        mysql-client \
        mysql-server \
        default-libmysqlclient-dev \
        apt-utils \
        curl \
        rsync \
        netcat \
        locales \
        sudo \
        python-software-properties \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        vim \
        wget \
        unzip \
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow && echo "airflow:airflow" | chpasswd && sudo adduser airflow sudo \
    && sudo echo 'airflow  ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
    && curl -fsSL https://yum.dockerproject.org/gpg | sudo apt-key add - \
    && apt-key fingerprint 58118E89F3A912897C070ADBF76221572C52609D \
    && sudo add-apt-repository \
       "deb https://apt.dockerproject.org/repo/ \
       ubuntu-xenial \
       main" \
    && sudo apt-get update \
    && sudo apt-get -y --allow-unauthenticated install docker-engine nvidia-modprobe \
    && wget -P /tmp https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.1/nvidia-docker_1.0.1-1_amd64.deb \
    && sudo dpkg -i /tmp/nvidia-docker*.deb \
    && pip install -U pip setuptools wheel \
    && pip install Cython \
    && pip install pytz \
    && pip install pyOpenSSL \
    && pip install ndg-httpsclient \
    && pip install pyasn1 \
    && pip install apache-airflow[crypto,celery,postgres,hive,jdbc,mysql]==$AIRFLOW_VERSION \
    && pip install 'celery[redis]>=4.1.1,<4.2.0' \
    && pip install setuptools \
    && pip install packaging \
    && pip install appdirs \
    && pip install six==1.10 \
    && pip install wheel \
    && pip install Cython \
    && pip install pytz==2015.7 \
    && pip install cryptography \
    && pip install psycopg2 \
    && pip install pandas==0.18.1 \
    && pip install celery==4.1.1 \
    && pip install kubernetes \
    && pip install https://github.com/docker/docker-py/archive/1.10.6.zip \
    && pip install apache-airflow[celery,postgres,hive,hdfs,jdbc]==$AIRFLOW_VERSION \
    && pip install httplib2 \
    && pip install "google-api-python-client>=1.5.0,<1.6.0" \
    && pip install "PyOpenSSL" \
    # flask-oauthlib required for airflow to use oauth
    # https://github.com/apache/incubator-airflow/blob/master/airflow/contrib/auth/backends/google_auth.py#L31
    && pip install flask-oauthlib \
    && pip install "oauth2client>=2.0.2,<2.1.0" \
    && pip install pandas-gbq \
    && apt-get purge --auto-remove -yqq $buildDeps \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

COPY script/entrypoint.sh /entrypoint.sh

RUN chown -R airflow: ${AIRFLOW_HOME}

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["/entrypoint.sh"]
CMD ["webserver"] # set default arg for entrypoint
