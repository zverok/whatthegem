require 'backports/latest'
require 'memoist'
require 'pp'
require 'hm'
require 'pathname'

class Object
  extend Memoist
  alias then yield_self # will be so in Ruby 2.6
end

class Pathname
  def glob(pattern) # exists in Ruby 2.5, but not in backports
    Dir.glob(self./(pattern).to_s).map(&Pathname.method(:new))
  end
end
