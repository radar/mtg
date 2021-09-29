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

    def select(...)
      @stack.select(...)
    end

    def add_effect(effect)
      puts "New effect added: #{effect}, requires_choices: #{effect.requires_choices?}"
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

    def next_effect
      @effects.first
    end

    def resolve_effect(effect, **args)
      if effect.single_choice?
        effect.resolve(target: effect.choices.first)
      else
        effect.resolve(**args)
      end

      @effects.shift
    end

    def resolve!
      resolve_stack!
      resolve_effects!
    end

    def resolve_stack!
      return if @stack.empty?
      return if pending_effects?

      item = @stack.shift
      unless item.countered?
        puts "Resolving #{item.name}"
        item.resolve!
        item.resolution_effects.each { |effect| add_effect(effect) }
      end

      resolve_effects!

      resolve_stack!
    end

    def resolve_effects!
      single_choice_effects = effects.select { |effect| effect.single_choice? }
      single_choice_effects.each do |effect|
        resolve_effect(effect)
      end
    end
  end
end
