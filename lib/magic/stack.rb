module Magic
  class Stack
    extend Forwardable

    def_delegator :@stack, :first

    attr_reader :effects

    def initialize(stack: [], effects: [])
      @stack = stack
      @effects = effects
    end

    def add(item)
      @stack.unshift(item)
    end

    def add_effect(effect)
      if effect.requires_choices?
        @effects << effect
        # wait for a choice to be made
      else
        effect.resolve
      end
    end

    def pending_effects?
      @effects.any?
    end

    def resolve_effect(type, **args)
      effect = @effects.first
      if effect.is_a?(type)
        effect.resolve(**args)
        @effects.shift
      else
        raise "Invalid type specified. Top effect is a #{effect.class}, but you specified #{type}"
      end
    end

    def resolve!
      return if @stack.empty?

      item = @stack.shift
      unless item.countered?
        puts "Resolving #{item.name}"
        item.resolve!
        item.resolution_effects.each { |effect| add_effect(effect) }
      end

      return if effects.any? { |effect| effect.requires_choices? }
      resolve!
    end
  end
end
