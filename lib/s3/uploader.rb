require 'aws/s3'
require 'yaml'

class S3Uploader

  def self.upload(folder)
    puts "Upload #{folder} to S3"
    connect()
    Dir.glob("#{folder}/**/*.*") do |filename|
      key = filename.gsub('albums/', '')
      File.open(filename) do |file|
        ok = AWS::S3::S3Object.store(key, file, @@bucket.name)
        putc ok ? '.' : 'e'
      end
    end
    puts
  end

  def self.connect
    AWS::S3::Base.establish_connection!(
      access_key_id:     config['aws_api_key'],
      secret_access_key: config['aws_secret_key']
    )
    @@bucket = AWS::S3::Bucket.find(config['bucket'])
  end

  def self.config
    @@config ||= YAML::load( File.open('./config/s3.yml') )
  end

end
