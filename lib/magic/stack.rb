module Magic
  class Stack
    extend Forwardable

    def_delegator :@stack, :first

    def initialize(stack: [])
      @stack = []
    end

    def add(item)
      @stack.unshift(item)
    end

    def resolve!

      @stack.each do |item|
        if item.is_a?(Card)
          item.add_to_battlefield!
          item.resolve!
        end
      end
      @stack.clear
    end
  end
end
