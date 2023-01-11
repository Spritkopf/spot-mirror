#FROM python:3.10.0-slim
FROM python:3-alpine

# install supercronic for periodic updates
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.1/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=d7f4c0886eb85249ad05ed592902fa6865bb9d70

RUN apk --no-cache add curl \
    && curl -fsSLO "$SUPERCRONIC_URL" \
    && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
    && chmod +x "$SUPERCRONIC" \
    && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
    && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

RUN apk --no-cache add gcc libc-dev ffmpeg \
    && pip3 install podcats spodcast

VOLUME ["/data"]
WORKDIR /data

COPY spodcast_crontab /etc

# Copy init script
COPY spodcast-init /usr/local/bin
RUN chmod +x /usr/local/bin/spodcast-init

# Copy episode download script
COPY download_episode /usr/local/bin
RUN chmod +x /usr/local/bin/download_episode

CMD ["/bin/bash", "-c", "echo Hello World"]

LABEL description="Monitor a folder and host a podcast RSS file for all \
media inside of it"