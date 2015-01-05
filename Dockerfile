FROM ubuntu:14.04

RUN apt-get update && \
    apt-get install -y ca-certificates libssl1.0.0 curl gcc file \
        libc6-dev libssl-dev make xz-utils zlib1g-dev libsqlite3-dev \
        libpcre++0 libpcre++-dev python-pip python-virtualenv \
        --no-install-recommends

WORKDIR /mod_wsgi-packages

RUN pip install zc.buildout boto

RUN buildout init

COPY buildout.cfg /mod_wsgi-packages/

RUN buildout -v -v

ENV TARBALL mod_wsgi-packages-heroku-cedar14-apache-2.4.10-1.tar.gz
ENV S3_BUCKET_NAME modwsgi.org

RUN tar cvfz $TARBALL apache apr-util apr

RUN ls -las $TARBALL

CMD s3put --access_key "$AWS_ACCESS_KEY_ID" \
          --secret_key "$AWS_SECRET_ACCESS_KEY" \
          --bucket "$S3_BUCKET_NAME" --prefix /mod_wsgi-packages/ $TARBALL
