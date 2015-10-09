FROM eeacms/plone-eea-common:5.2
MAINTAINER "Alex Eftimie <alex.eftimie@eaudeweb.ro>"

COPY versions.cfg /opt/zope/versions.cfg
RUN ./install.sh
