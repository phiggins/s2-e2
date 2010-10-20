require 'mini_factory/proxy'
require 'mini_factory/sequence'

class MiniFactory
  def self.clear_state!
    @factories = nil
    @sequences = nil
  end

  def self.sequences
    @sequences ||= {}
  end

  def self.sequence name, &block
    sequences[name] = Sequence.new(block)
  end

  def self.next name
    sequences[name].next
  end

  def self.factories
    @factories ||= {}
  end
  
  def self.define name, opts={}, &block
    name = name.to_s.downcase.to_sym
    
    parent = opts.delete(:parent)
    opts[:parent] = factories[parent] if parent

    factories[name] = new(name, opts, block)
  end

  def self.create name, opts={}
    name = name.to_s.downcase.to_sym
    factory = factories[name]
    factory.create(opts)
  end

  attr_reader :name, :block, :model

  def initialize name, opts={}, block
    @name   = name

    @parent = opts[:parent]

    if @parent
      @block = lambda do |obj|
        block.call(obj)
        @parent.block.call(obj)
      end

      @model = @parent.model
    else
      @block  = block
      @model  = opts[:class] || model
    end
  end

  def create opts
    real_object = @model.new
    proxy = Proxy.new(self, real_object)
    opts.each {|k,v| proxy.send(k,v) }
    @block.call(proxy)
    real_object.save
    real_object
  end

  def model
    Object.const_get(@name.to_s.capitalize)
  end
  
  def sequences
    @sequences ||= {}
  end

  def sequence name, block
    sequences[name] ||= Sequence.new(block)
    sequences[name].next
  end
end

def MiniFactory(name, opts={})
  MiniFactory.create(name, opts) 
end
