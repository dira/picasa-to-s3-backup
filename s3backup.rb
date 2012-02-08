require 'fileutils'
require './lib/picasa_error.rb'
require './lib/picasa.rb'

class S3Backup

  def initialize(picasa_username)
    @picasa_username = picasa_username
  end

  def run
    albums[1..1].each do |json|
      sync_album(json)
    end
  end

  def sync_album(json)
    folder = PicasaDownloader.sync_album(json, albums_folder)
    p folder
  end

private

  def albums
    @albums = PicasaDownloader.albums(@picasa_username)[:albums]
  end

  def albums_folder
    File.join(File.dirname(__FILE__), 'albums')
  end

end

class PicasaDownloader

  def self.albums(username)
    PicasaAPI.get_albums(username)
  end

  def self.sync_album(json, folder)
    p "Synch #{json[:title]}"
    folder = File.join(folder, "#{json[:id]}-#{json[:title]}")
    FileUtils.mkdir_p folder

    # get photos
    photos_json = PicasaAPI.get_photos(json[:username], json[:id])
    status = photos_json[:photos][0..2].map do |photo|
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
      folder
    else
      nil
    end
  end

end


S3Backup.new('irina.dumitrascu').run


# require 'aws/s3'
# require 'yaml'

# source = '/Users/dira/Pictures/Downloaded Albums'
# username = 'irina.dumitrascu'
# bucket_name = 'picasa-backup'
# config = YAML::load( File.open('./config.yml') )

# AWS::S3::Base.establish_connection!(
  # access_key_id:     config['aws_api_key'],
  # secret_access_key: config['aws_secret_key']
# )
# AWS::S3::DEFAULT_HOST.replace 's3-eu-west-1.amazonaws.com'
# # bucket = AWS::S3::Bucket.find(bucket_name)
# # p Time.parse(bucket.objects.first.about["last-modified"])

# Dir.glob("#{source}/#{username}/**/*.{jpg,JPG}") do |filename|
  # key = filename.gsub(source + '/', '')
  # p key
  # File.open(filename) do |file|
    # AWS::S3::S3Object.store(key, file, bucket_name)
  # end
# end
