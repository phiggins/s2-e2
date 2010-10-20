class MiniFactory
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
end
