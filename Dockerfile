FROM ubuntu:lucid
MAINTAINER Helmi Ibrahim <helmi@tuxuri.com>

RUN echo "deb http://archive.ubuntu.com/ubuntu lucid main universe" > /etc/apt/sources.list \
&& echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections 
ENV http_proxy http://archive.ubuntu.com
RUN apt-get -y update \
&& apt-get install -y ca-certificates \
&& apt-get -y install wget 
ENV https_proxy https://www.postgresql.org
RUN wget --quiet -O - http://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
&& echo "deb http://apt.postgresql.org/pub/repos/apt/ lucid-pgdg main" > /etc/apt/sources.list 
ENV http_proxy http://apt.postgresql.org
RUN apt-get -y update \
&& apt-get -y upgrade \
&& locale-gen --no-purge en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8 
ENV https_proxy https://www.postgresql.org
ENV http_proxy http://apt.postgresql.org
RUN apt-get -y install postgresql-9.0 postgresql-contrib-9.0 postgresql-9.0-postgis-2.1 postgis \
&& echo "host    all             all             0.0.0.0/0               md5" >> /etc/postgresql/9.0/main/pg_hba.conf \ 
&& service postgresql start && /bin/su postgres -c "createuser -d -s -r -l docker" && /bin/su postgres -c "psql postgres -c \"ALTER USER docker WITH ENCRYPTED PASSWORD 'docker'\"" && service postgresql stop \
&& echo "listen_addresses = '*'" >> /etc/postgresql/9.0/main/postgresql.conf \
&& echo "port = 5432" >> /etc/postgresql/9.0/main/postgresql.conf

EXPOSE 5432

ADD start.sh /start.sh
RUN chmod 0755 /start.sh

CMD ["/start.sh"]
