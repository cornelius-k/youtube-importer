# Youtube import script -- import discogs.com data dump to redis database
# created by Neil Kempin neilkempin@gmail.com

require 'yaml'
require 'redis'
require 'nokogiri'
require 'pry'

# configuration
config = YAML.load_file('config.yaml')
env = ENV['discogs-auto-dig-env'] || 'local'

# connect to redis
redis = Redis.new(host: config[env]['host'], port: config[env]['port'])

# find xml file, multiple files not supported
filename = Dir.glob('*_masters.xml').first

# parse release id and youtube video urls from nokogiri xml node
class NodeHandler < Struct.new(:node)
  def parse
    release_id = node.xpath('main_release').children.text
    youtube_videos = []
    node.xpath('videos/video').each do |video_node|
      title = video_node.xpath('title').text
      url = video_node.attr('src')
      youtube_videos.push({title: title, url: url})
    end
    return release_id, youtube_videos
  end

  def node_has_content
    return !node.children.empty?
  end
end

# read XML file line by line due to large file size
Nokogiri::XML::Reader(File.open(filename)).each do |node|
  if node.name == 'master'
    node_handler = NodeHandler.new( Nokogiri::XML(node.outer_xml).at('master') )

    # write valid entries to db
    if node_handler.node_has_content
      release_id, youtube_videos = node_handler.parse()
      puts "writing #{release_id}: #{youtube_videos}" +
        redis.set(release_id, youtube_videos)
    end
  end
end
