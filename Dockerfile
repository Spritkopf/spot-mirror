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

# Copy run script
COPY run.sh /usr/local/bin
RUN chmod +x /usr/local/bin/run.sh

ENV FEED_HOST  0.0.0.0
ENV FEED_PORT  9900
ENV FEED_TITLE MyFeedMirror
ENV TIMEOUT_RETRY_NUM   10

ENTRYPOINT ["/usr/local/bin/run.sh"]

LABEL description="Monitor a Spotify podcast, download episodes and host them locally"