require File.join(File.dirname(__FILE__), 'lib', 'picasa', 'downloader.rb')

PicasaDownloader.albums[:albums].reverse.each do |json|
  puts "#{json[:id]} #{json[:title]}"
end
