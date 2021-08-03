FROM fedora:27
MAINTAINER Michael Scherer <mscherer@redhat.com>


LABEL \
      # Location of the STI scripts inside the image.
      io.openshift.s2i.scripts-url=image:///usr/libexec/s2i \
      io.k8s.description="Platform for building and running Hugo blog website" \
      io.k8s.display-name="Hugo builder, Fedora 27" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,hugo"


ENV \
    STI_SCRIPTS_PATH=/usr/libexec/s2i \
    HOME=/opt/app-root/src \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:$PATH
RUN mkdir -p /opt/app-root/src
RUN useradd -u 1001 -r -g 0 -d ${HOME} -s /sbin/nologin -c "Default Application User" default
RUN chown -R 1001:0 /opt/app-root
RUN dnf install -y tar bsdtar shadow-utils git ; dnf clean all

RUN dnf install -y nginx ; dnf clean all
RUN /usr/bin/chmod -R 770 /var/{lib,log}/nginx/ && chown -R :root /var/{lib,log}/nginx/
COPY ./s2i/nginx.conf  /etc/nginx/nginx.conf


RUN dnf install -y hugo ; dnf clean all

COPY ./s2i/bin/ $STI_SCRIPTS_PATH
WORKDIR ${HOME}

USER 1001

EXPOSE 8080
# Set the default CMD to print the usage of the language image
CMD $STI_SCRIPTS_PATH/usage

