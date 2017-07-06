# Youtube importer for Discogs Auto Dig tool
  Parses youtube videos for each release from a Discogs data dump in xml format
  and writes to a key-value store.

  XML data dumps for masters can be found monthly at http://data.discogs.com/
  and follow a file naming scheme like `discogs_20170701_masters.xml.gz`

  ### config
  - edit `config.yaml` to include production or local redis configuration
  - export `discogs-auto-dig-env=production` environment variable, or hardcode

  ### run
  - configure redis creds
  - place unzipped xml file in project directory
  - run youtube_importer.rb
