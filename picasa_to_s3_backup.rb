require './lib/picasa_to_s3.rb'

engine = PicasaToS3.new('irina.dumitrascu', File.dirname(__FILE__))
engine.run
