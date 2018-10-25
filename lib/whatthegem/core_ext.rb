require 'backports/latest'
require 'memoist'
require 'pp'
require 'hm'

class Object
  extend Memoist
  alias then yield_self # will be so in Ruby 2.6
end