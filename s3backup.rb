require 'aws/s3'
require 'yaml'

source = '/Users/dira/Pictures/Downloaded Albums'
username = 'irina.dumitrascu'
bucket_name = 'picasa-backup'
config = YAML::load( File.open('./config.yml') )

AWS::S3::Base.establish_connection!(
  access_key_id:     config['aws_api_key'],
  secret_access_key: config['aws_secret_key']
)
AWS::S3::DEFAULT_HOST.replace 's3-eu-west-1.amazonaws.com'

Dir.glob("#{source}/#{username}/**/*.{jpg,JPG}") do |filename|
  key = filename.gsub(source + '/', '')
  p key
  File.open(filename) do |file|
    AWS::S3::S3Object.store(key, file, bucket_name)
  end
end
