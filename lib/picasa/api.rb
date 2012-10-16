require 'net/http'
require 'json'
require File.join(File.dirname(__FILE__), 'error.rb')

class PicasaAPI
  API_BASE = 'http://picasaweb.google.com/data/feed/api'

  def  self.api_url_user(username)
    global_fields = 'id'
    entry_fields = 'title,gphoto:id,gphoto:name,gphoto:numphotos,gphoto:user,updated'
    URI.parse("#{API_BASE}/user/#{URI.escape(username)}?alt=json&fields=#{global_fields},entry(#{entry_fields})")
  end

  def self.api_url_album(username, album_id)
    global_fields = "gphoto:id,title,updated"
    entry_fields = "content,media:group(media:description),gphoto:id,gphoto:timestamp,title,gphoto:width,gphoto:height"
    URI.parse("#{API_BASE}/user/#{URI.escape(username)}/albumid/#{URI.escape(album_id)}?alt=json&imgmax=d&fields=#{global_fields},entry(#{entry_fields})")
  end

  def self.get_albums(username)
    response = Net::HTTP.get_response(PicasaAPI::api_url_user(username))
    raise LightPicasaError unless response.is_a? Net::HTTPOK

    feed = JSON.parse(response.body)['feed']
    albums = (feed['entry'] || []).map do |album|
      { title:     album['title']['$t'],
        id:        album['gphoto$id']['$t'],
        uri:       album['gphoto$name']['$t'],
        nr_photos: album['gphoto$numphotos']['$t'],
        username:  album['gphoto$user']['$t'],
        updated:   album['updated']['$t'],
      }
    end
    { albums: albums }
  end

  def self.get_photos(username, album_id)
    response = Net::HTTP.get_response(PicasaAPI::api_url_album(username, album_id))
    raise LightPicasaError unless response.is_a? Net::HTTPOK

    feed = JSON.parse(response.body)['feed']
    photos = (feed['entry'] || []).map do |photo|
      { src: photo["content"]["src"],
        id: photo["gphoto$id"]["$t"],
        title: photo["title"]["$t"],
        description: photo["media$group"]["media$description"]["$t"],
        width: photo["gphoto$width"]["$t"],
        height: photo["gphoto$height"]["$t"],
        time: Time.at(photo["gphoto$timestamp"]["$t"].to_i / 1000).utc,
      }
    end
    { id:      feed['gphoto$id']['$t'],
      title:   feed['title']['$t'],
      updated: feed['updated']['$t'],
      photos:  photos,
    }
  end

end
