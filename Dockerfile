
# rails4-centos7
#FROM openshift/base-centos7
FROM centos:centos7

# TODO: Put the maintainer name in the image metadata
MAINTAINER Miguel Z <miguelzuniga@gmail.com>

# TODO: Rename the builder environment variable to inform users about application you provide them
ENV RAILS_VERSION 4.0

# TODO: Set labels used in OpenShift to describe the builder image
LABEL io.k8s.description="Platform for serving rails 4 applications running on passenger apache" \
      io.k8s.display-name="rails 4" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,ruby,rails,passenger,apache"

# TODO: Install required packages here:

RUN yum install -y sqlite-devel sqlite patch wget readline readline-devel libcurl-devel gcc gcc-c++ libxml2 libxml2-devel libxslt libxslt-devel libxml libssl openssl-devel libssl-devel openssl libyaml httpd-devel httpd \
	&& wget https://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.3.tar.gz -O /tmp/ruby-2.2.3.tar.gz \
        && cd /opt \
        && tar xvfz /tmp/ruby-2.2.3.tar.gz \
        && cd ruby-2.2.3 \
        && ./configure --prefix=/opt/ruby && make && make install \
        && export PATH=/opt/ruby/bin:$PATH \
        && gem install rails --no-ri --no-rdoc \
        && gem install passenger --no-ri --no-rdoc \
        && passenger-install-apache2-module -a --languages 'ruby' \
        && passenger-install-apache2-module --languages 'ruby' --snippet > /etc/httpd/conf.d/passenger.conf \
        && rm -rf /tmp/ruby-* \
        && rm -rf /opt/ruby-2.2.3* \
        && mkdir -p /opt/app-root/src \
        && yum clean all -y


# TODO (optional): Copy the builder files into /opt/app-root
# COPY ./<builder_folder>/ /opt/app-root/

# TODO: Copy the S2I scripts to /usr/local/s2i, since openshift/base-centos7 image sets io.openshift.s2i.scripts-url label that way, or update that label
LABEL io.openshift.s2i.scripts-url=image:///usr/local/s2i
COPY ./.s2i/bin/ /usr/local/s2i

# Copy apache rails config file
COPY ./etc/rails.conf /etc/httpd/conf.d/

# TODO: Drop the root user and make the content of /opt/app-root owned by user 1001
RUN chown -R apache.apache /opt/app-root
RUN chmod -R 777 /opt/app-root

# This default user is created in the openshift/base-centos7 image
USER root

# TODO: Set the default port for applications built using this image
EXPOSE 8080

# TODO: Set the default CMD for the image
CMD ["usage"]
