require File.join(File.dirname(__FILE__), 's3_backup.rb')
require File.join(File.dirname(__FILE__), 'picasa_downloader.rb')

class PicasaToS3

  def initialize(picasa_username, base_folder)
    @picasa_username = picasa_username
    @base_folder = base_folder
    @s3_backup = S3Backup.new
  end

  def run
    albums.each do |json|
      sync_album(json)
    end
  end

  def sync_album(json)
    json = albums[json.to_i] if json.respond_to?(:to_i)
    folder = PicasaDownloader.sync_album(json, albums_folder)
    @s3_backup.sync(albums_folder, folder) if folder
  end

private

  def albums
    @albums ||= PicasaDownloader.albums(@picasa_username)[:albums]
  end

  def albums_folder
    File.join(@base_folder, 'albums', @picasa_username)
  end

end
