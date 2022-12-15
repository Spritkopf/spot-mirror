FROM python:3-alpine

RUN apk --no-cache add bash && pip3 install podcats

VOLUME ["/data"]
WORKDIR /data

COPY run.sh /run.sh

ENTRYPOINT ["/run.sh"]

LABEL description="Monitor a folder and host a podcast RSS file for all \
media inside of it"