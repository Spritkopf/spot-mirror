FROM heywoodlh/spodcast:latest

RUN pip3 install podcats

VOLUME ["/data"]
WORKDIR /data

COPY run.sh /new_run.sh

ENTRYPOINT ["/new_run.sh"]

LABEL description="Monitor a folder and host a podcast RSS file for all \
media inside of it"