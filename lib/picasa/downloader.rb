require 'fileutils'
require 'yaml'
require File.join(File.dirname(__FILE__), 'api.rb')

class PicasaDownloader


  def self.albums
    puts "Downloading the list of albums for #{username}"
    PicasaAPI.get_albums(self.username)
  end

  def self.config
    @config ||= YAML::load( File.open(File.join('.', 'config', 'picasa.yml')))
  end

  def self.username
    config["username"]
  end

  def self.album_name(json)
    "#{json[:id]}-#{json[:title]}"
  end

  def self.download(id)
    # get photos
    json = PicasaAPI.get_photos(username, id)

    puts "Downloading #{json[:title]}"
    folder_name = album_name(json)
    folder = File.join('.', 'albums', username, folder_name)
    FileUtils.mkdir_p folder

    status = json[:photos].map do |photo|
      response = Net::HTTP.get_response(URI.parse(photo[:src])) rescue nil
      if response != nil and response.is_a? Net::HTTPOK
        putc '.'
        File.open(File.join(folder, "#{photo[:id]}-#{photo[:title]}" ), 'w') do |f|
          f.write response.body
        end
        true
      else
        putc 'e'
        false
      end
    end
    puts

    # save the full json
    json[:photos] = json
    File.open(File.join(folder, 'data.json'),      'w') { |f| f.write json }

    if status.all?
      # save updated at
      File.open(File.join(folder, 'updated_at.txt'), 'w') { |f| f.write json[:updated] }
      folder_name
    else
      nil
    end
  end
end
