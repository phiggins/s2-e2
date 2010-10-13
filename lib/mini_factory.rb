class MiniFactory
  def self.define model, &block
    @factories ||= {}
    @factories[model] = block
  end

  def self.create name
    model = symbol_to_model(name)
    record = model.new
    @factories[ model ].call( record )
    record.save
    record
  end

  def self.symbol_to_model symbol
    Object.const_get symbol.to_s.capitalize
  end
end

def MiniFactory(name, attrs={})
  MiniFactory.create(name) 
end
