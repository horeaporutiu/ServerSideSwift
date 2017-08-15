FROM ibmcom/swift-ubuntu:3.1.1
MAINTAINER IBM Swift Engineering at IBM Cloud
LABEL Description="Docker image for building and running the ttsServer sample application."

# Expose default port for Kitura
EXPOSE 8080

RUN mkdir /root/ttsServer

ADD Sources /root/ttsServer/Sources
ADD public /root/ttsServer/public
ADD Package.swift /root/ttsServer
ADD Package.pins /root/ttsServer
ADD LICENSE /root/ttsServer
ADD .swift-version /root/ttsServer

RUN cd /root/ttsServer && swift build

USER root
#CMD ["/root/ttsServer/.build/debug/ttsServer"]
CMD [ "sh", "-c", "cd /root/ttsServer && .build/debug/ttsServer" ]
