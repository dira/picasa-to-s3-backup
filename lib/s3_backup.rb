class S3Backup

  require 'aws/s3'
  require 'yaml'

  def initialize
    AWS::S3::Base.establish_connection!(
      access_key_id:     config['aws_api_key'],
      secret_access_key: config['aws_secret_key']
    )
    AWS::S3::DEFAULT_HOST.replace 's3-eu-west-1.amazonaws.com'
    @bucket = AWS::S3::Bucket.find(config['bucket'])
  end

  def config
    @config = YAML::load( File.open('./config.yml') )
  end

  def sync(base_path, folder)
    p "Save #{folder} to S3"
    Dir.glob("#{base_path}/#{folder}/**/*.{jpg,JPG}") do |filename|
      key = filename.gsub(base_path + '/', '')
      File.open(filename) do |file|
        ok = AWS::S3::S3Object.store(key, file, @bucket.name)
        putc ok ? '.' : 'e'
      end
    end
    puts
  end

end
