ARG FROM_TAG=latest
FROM us-docker.pkg.dev/fathom-containers/us.gcr.io/docker-airflow-two:${FROM_TAG}
USER root
COPY requirements.txt /usr/local/airflow
RUN pip install --no-cache-dir -r requirements.txt
USER airflow