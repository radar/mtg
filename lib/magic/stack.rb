module Magic
  class Stack
    extend Forwardable

    def_delegators :@stack, :first, :select, :count

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
        puts "Only one choice for #{effect}, automatically applying."
        if effect.multiple_targets?
          effect.resolve(targets: [effect.choices.first])
        else
          effect.resolve(target: effect.choices.first)
        end
      else
        effect.resolve(**args)
      end

      @effects.shift
    end

    def skip_effect(effect)
      puts "#{effect} has no valid choices, skipping."
      @effects.delete(effect)
    end

    def resolve!
      resolve_stack!
      resolve_effects!
    end

    def resolve_stack!
      return if @stack.empty?
      if pending_effects?
        puts "Pending effects, pausing stack resolution."
        return
      end

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

      no_choice_effects = effects.select { |effect| effect.no_choice? }

      no_choice_effects.each do |effect|
        skip_effect(effect)
      end
    end
  end
end
