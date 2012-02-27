require File.join(File.dirname(__FILE__), 'lib', 's3', 'uploader.rb')

puts S3Uploader.upload(ARGV[0])
