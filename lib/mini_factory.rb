class MiniFactory
  def self.clear_factories!
    @factories = nil
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
    proxy = Proxy.new(real_object)
    opts.each {|k,v| proxy.send(k,v) }
    @block.call(proxy)
    real_object.save
  end

  def model
    Object.const_get(@name.to_s.capitalize)
  end

  class Proxy
    attr_reader :target

    def initialize target
      @target   = target
      @proxied  = []
    end

    def proxied? method
      @proxied.include? method.to_s
    end
  
    def proxied method
      @proxied << method.to_s
    end

    def method_missing method, *args, &block
      unless proxied? method
        if block
          @target.send( "#{method}=", block.call(@target) )
        else
          @target.send( "#{method}=", *args )
        end
        
        proxied method
      end
    end
  end
end

def MiniFactory(name, attrs={})
  MiniFactory.create(name, attrs) 
end
