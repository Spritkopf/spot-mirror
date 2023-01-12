# spot-mirror

Monitor a Spotify podcast, download episodes and host them locally

This is the repository for my spot-mirror Docker image.
The image contains 3 tools:
* [spodcast](https://github.com/Yetangitu/Spodcast) - Download Spotify podcast episodes
* [podcats](https://github.com/jakubroztocil/podcats) - Generate an RSS feed from the downloaded episodes and host it locally
* [supercronic](https://github.com/aptible/supercronic) - a crontab-compatible job runner, designed specifically to run in containers

**Note**: Even though spodcast has a built-in RSS feed generator, it needs an external PHP-capable webserver to generate the RSS and serve its (admittedly pretty cool) web interface. Since I only want the RSS feed it feels a bit too much, so I'd rather save the resources.

## Usage

## Build the image
```bash
docker build -t spot-mirror:latest .
```
### Preface
`spodcast` needs your Spotify login credentials to access the Spotify API. You provide them via environment variables to the container. It is recommended to put them into an `.env` file
```
# .env
SPOTIFY_USER=<username>
SPOTIFY_PW=<password>
```

### Docker run
```bash
$ docker run -d -v /your/data/dir:/data -p 9900:9900 -e SPOT_URL_0=https://open.spotify.com/show/SHOW_ID -e SPOT_CRON_0="0 0 5 * * WED *" --env-file .env  spot-mirror:latest
```

### docker-compose
```bash
version: "3.9"
services:

  spot-mirror:
    image: spot-mirror:latest
    container_name: spot-mirror
    restart: unless-stopped
    ports:
      - "9900:9900"
    environment:
      - FEED_HOST=0.0.0.0
      - FEED_PORT=9900
      - FEED_TITLE=MyPodcastFeed
      - SPOT_URL_0=https://open.spotify.com/show/SHOW_ID
      - SPOT_CRON_0=0 0 5 * * WED *
    env_file:
      - .env
    volumes:
      - /your/data/dir:/data

```

## Selecting show and schedule

The Spotify show and timeplan when to download it is selected by an pair of environment variables, see example above:
```
- SPOT_URL_0=https://open.spotify.com/show/SHOW_ID
- SPOT_CRON_0=0 0 5 * * WED *
```
This downloads the show with ID `SHOW_ID` every Wednesday at 5 am. Refer to the [supercronic](https://github.com/aptible/supercronic) repo for format details.

Add additional shows by incrementing the number, e.g. SPOT_URL_1, SPOT_URL_2. Every SPOT_URL_N needs a corresponding SPOT_CRON_N variable.

## Variables
* `FEED_HOST` - hostname used by `podcats`
* `FEED_PORT` - port used by `podcats`
* `FEED_TITLE` - Title of the feed as hosted by `podcats`
* `SPOT_URL_N` - See section above
* `SPOT_CRON_N`= See section above

## Known issues

Sometimes, `spodcast` times out while accessing the Spotify API. The internal script uses retries to work around that. However, the API timeout is around 2 minutes. That means the first startup of the container may take a while in some cases. If it appears to hang, just wait a short while. 