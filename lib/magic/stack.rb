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
  end
end
