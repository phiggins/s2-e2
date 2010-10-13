class MiniFactory
  class << self 
    attr_accessor :factories
  end
  
  def self.define name, &block
    name = name.to_s.downcase.to_sym
    @factories ||= {}
    @factories[name] = block
  end

  def self.create name
    name = name.to_s.downcase.to_sym
    model = model(name)
    proxy = Proxy.new(model.new)
    @factories[name].call( proxy )
    record = proxy.target
    record.save
    record
  end

  def self.model obj
    Object.const_get obj.to_s.capitalize
  end

  class Proxy
    attr_reader :target

    def initialize target
      @target = target
    end

    def method_missing method, *args, &block
      @target.send( "#{method}=", *args, &block )
    end
  end
end

def MiniFactory(name, attrs={})
  MiniFactory.create(name) 
end
