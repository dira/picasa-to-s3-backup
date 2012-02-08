require 'fileutils'
require File.join(File.dirname(__FILE__), 'picasa.rb')

class PicasaDownloader


  def self.albums(username)
    p 'Downloading the list of albums'
    PicasaAPI.get_albums(username)
  end

  def self.sync_album(json, base_folder)
    p "Download #{json[:title]}"
    folder_name = "#{json[:id]}-#{json[:title]}"
    folder = File.join(base_folder, folder_name)
    FileUtils.mkdir_p folder

    # get photos
    photos_json = PicasaAPI.get_photos(json[:username], json[:id])
    status = photos_json[:photos].map do |photo|
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

    if status.all?
      # save the full json
      json[:photos] = photos_json
      File.open(File.join(folder, 'data.json'),      'w') { |f| f.write json }
      # save updated at
      File.open(File.join(folder, 'updated_at.txt'), 'w') { |f| f.write json[:updated] }
      folder_name
    else
      nil
    end
  end

end

