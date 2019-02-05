require 'backports/latest'
require 'memoist'
require 'pp'
require 'hm'
require 'pathname'
require 'forwardable'

class Object
  extend Memoist
  alias then yield_self # will be so in Ruby 2.6
  alias :_class :class
end

Module.include Forwardable

class Pathname
  def glob(pattern) # exists in Ruby 2.5, but not in backports
    Dir.glob(self./(pattern).to_s).map(&Pathname.method(:new))
  end
end

class Hm
  class << self
    alias call new
  end

  def self.to_proc
    proc { |val| new(val) }
  end
end