FROM registry.access.redhat.com/ubi9/openjdk-21:latest AS builder
WORKDIR /build
ARG APP

COPY --chown=1000:0 . /build/$APP
RUN whoami && id
#RUN echo $APP && cd /build/$APP && tar -xf m2.tar && mvn -o clean package -Dmaven.repo.local=/build/$APP/.m2/repository
USER 0
#USER 0
#RUN dnf install -y procps-ng && dnf clean all
RUN microdnf install -y  procps-ng procps curl tar gzip jq  procps util-linux vim-minimal iputils net-tools
USER 1000
RUN echo $APP && cd /build/$APP && mvn clean package 

FROM icr.io/appcafe/websphere-liberty:25.0.0.2-kernel-java21-openj9-ubi-minimal
ARG APP
ARG TLS=true
USER 0
#RUN dnf install -y procps-ng && dnf clean all
#RUN dnf update -y && dnf install -y curl tar gzip jq  procps util-linux vim-minimal iputils net-tools
USER 1001

COPY --from=builder --chown=1001:0  /build/$APP/target/*.*ar /config/apps/
COPY --from=builder --chown=1001:0  /build/$APP/src/main/liberty/config/ /config/


# This script will add the requested XML snippets to enable Liberty features and grow image to be fit-for-purpose using featureUtility.
# Only available in 'kernel-slim'. The 'full' tag already includes all features for convenience.
ENV VERBOSE=false

RUN features.sh
# Add interim fixes (optional)
# COPY --chown=1001:0  interim-fixes /opt/ibm/wlp/fixes/

# This script will add the requested server configurations, apply any interim fixes and populate caches to optimize runtime
RUN bash configure.sh 
