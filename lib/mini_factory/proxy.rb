class MiniFactory
  class Proxy
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

    def association name, opts={}
      @factory.class.create(name, opts)
    end

    def sequence name, &block
      send(name, @factory.sequence(name, block))
    end

    def method_missing method, *args, &block
      if proxied?(method)
        @target.send(method)
      else
        val = block ? block.call(self) : args.first
        @target.send( "#{method}=", val )
        
        proxied method
      end
    end
  end
end

