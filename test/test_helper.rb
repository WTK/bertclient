require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'bert'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

load 'bertclient_new.rb'

def to_bytes(str)
  bytes = []
  str.each_byte {|b| bytes << b }
  bytes
end