class MiniFactory
  def self.clear_factories!
    @factories = nil
  end

  def self.factories
    @factories ||= {}
  end
  
  def self.define name, opts={}, &block
    name = name.to_s.downcase.to_sym
    factories[name] = new(name, opts, block)
  end

  def self.create name
    name = name.to_s.downcase.to_sym
    factory = factories[name]
    factory.create
  end

  def initialize name, opts={}, block
    @name   = name
    @block  = block
    @model  = opts[:class] || model
  end

  def create
    real_object = @model.new
    proxy = Proxy.new(real_object)
    @block.call(proxy)
    real_object.save
  end

  def model
    Object.const_get @name.to_s.capitalize
  end

  class Proxy
    attr_reader :target

    def initialize target
      @target = target
    end

    def method_missing method, *args, &block
      if block
        @target.send( "#{method}=", block.call )
      else
        @target.send( "#{method}=", *args )
      end
    end
  end
end

def MiniFactory(name, attrs={})
  MiniFactory.create(name) 
end
