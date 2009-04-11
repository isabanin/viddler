$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'active_support'
require 'ostruct'

require 'ext/open_struct'
require 'ext/hash'
require 'ext/array'
require 'viddler/api_spec'
require 'viddler/base'
require 'viddler/multipart_params'
require 'viddler/request'
require 'viddler/video'
require 'viddler/comment'
require 'viddler/user'

# Module to encapsule the Viddler API.
module Viddler
end