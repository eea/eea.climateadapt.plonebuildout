FROM eeacms/plone-eea-common:5.2
MAINTAINER "Alex Eftimie <alex.eftimie@eaudeweb.ro>"

COPY base.cfg /opt/zope/base.cfg
COPY sources.cfg /opt/zope/sources.cfg
COPY versions.cfg /opt/zope/versions.cfg
RUN ./install.sh
