FROM eeacms/plone-eea-common:5.2
MAINTAINER "Alex Eftimie <alex.eftimie@eaudeweb.ro>"

COPY base.cfg /opt/zope/base.cfg
COPY custom-versions.cfg /opt/zope/custom-versions.cfg
COPY sources.cfg /opt/zope/sources.cfg

USER root
RUN ./install.sh
USER zope-www
