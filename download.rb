require File.join(File.dirname(__FILE__), 'lib', 'picasa', 'downloader.rb')

puts PicasaDownloader.download(ARGV[0])
