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
  end

  def model
    Object.const_get(@name.to_s.capitalize)
  end
  
  def sequences
    @sequences ||= {}
  end

  def sequence name, block
    s = Sequence.new(block)
    sequences[name] = s
    s.next
  end

  class Sequence
    def initialize block
      @block  = block
      @n      = 0
    end

    def next
      @n += 1
      @block.call(@n)
    end
  end

  class Proxy
    attr_reader :target

    def initialize factory, target
      @factory  = factory
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
      case
      when method == :sequence
        name = args.first
        sequences = @factory.sequences
        val = if sequences[name]
          sequences[name].next
        else
          @factory.sequence(name, block)
        end

        send(name, val)
      when proxied?(method)
        # no-op
      else
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
