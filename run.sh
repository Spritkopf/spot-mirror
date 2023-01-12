#!/bin/sh

# Create crontab from environment variables:
# SPOT_URL_N and SPOT_CRON_N where N can be any number
# SPOT_URL_N holds the sporitfy URL which is passed to spodcast for download
# SPOT_CRON_N holds the crontab definition for the cron deamon (e.g. * * * * *, etc)

CRONTAB_FILE=/etc/crontab_generated

rm -f ${CRONTAB_FILE}

# Create crontab
# Iterate through all environment variables
# base idea stolen from https://stackoverflow.com/questions/25765282/bash-loop-through-variables-containing-pattern-in-name
while IFS='=' read -r name value ; do
  if [[ $name == 'SPOT_URL_'* ]]; then
    number=$(echo "$name" | sed -r 's/.*_([0-9]*)$/\1/g')
    
    combined=SPOT_CRON_${number}
    
    eval cron_string=\$$combined
    echo "# ${number}: ${value}" >> ${CRONTAB_FILE}
    echo "${cron_string} download_episode ${value}" >> ${CRONTAB_FILE}
    echo "" >> ${CRONTAB_FILE}
  fi
done < <(env)

# check crontab for errors
supercronic -test ${CRONTAB_FILE}

# run supercronic
supercronic ${CRONTAB_FILE} &

# serve podcast XML
podcats serve --host ${FEED_HOST} --port ${FEED_PORT} --title ${FEED_TITLE} /data/output