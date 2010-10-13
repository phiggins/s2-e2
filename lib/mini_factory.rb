class MiniFactory
  def self.define model, &block
    @factories ||= {}
    @factories[model] = block
  end

  def self.create name
    model = symbol_to_model(name)
    proxy = Proxy.new(model.new)
    @factories[ model ].call( proxy )
    record = proxy.target
    record.save
    record
  end

  def self.symbol_to_model symbol
    Object.const_get symbol.to_s.capitalize
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
