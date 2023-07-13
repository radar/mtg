module Magic
  class Stack
    extend Forwardable

    def_delegators :@stack, :first, :select, :count, :include?, :map, :empty?

    attr_reader :logger, :effects

    class TargetedCast
      class InvalidTarget < StandardError; end

      attr_reader :card

      def initialize(card, targets:)
        @card = card
        @targets = targets
      end

      def name
        card.name
      end

      def validate!
        raise InvalidTarget if @targets.any? { |target| !card.target_choices.include?(target) }
      end

      def resolve!
        card.resolve!(target: @targets.first)
      end
    end

    def initialize(logger: Logger.new($stdout), stack: [], effects: [])
      @logger = logger
      @stack = stack
      @effects = Effects.new(effects)
    end

    def add(item)
      @stack.unshift(item)
    end

    def exile!
      @stack.each(&:exile!)
      @stack.clear
    end


    def spells
      @stack.select { |item| item.is_a?(Magic::Actions::Cast) }
    end

    def cards
      @stack.map do |item|
        item.respond_to?(:card) ? item.card : item
      end
    end

    def add_effect(effect)
      logger.debug "New effect added: #{effect}, choice required: #{effect.requires_choices?}"

      if effect.requires_choices?
        if effect.single_choice?
          logger.debug "Only one choice for #{effect}: #{effect.choices.first}, resolving effect immediately."
          effect.resolve(effect.choices.first)
        else
          @effects << effect
          # wait for a choice to be made
        end
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

    def resolve_pending_effect(...)
      logger.debug "Resolving effect: #{effects.first}"
      effects.shift.resolve(...)
    end

    def resolve_single_target_effect(effect)
      logger.debug "Resolving single target effect: #{effect}"
      effect.resolve(effect.choices.first)

      effects.shift
    end

    def skip_effect(effect)
      effects.shift
      effect.skip!
    end

    def resolve!
      resolve_stack!
      resolve_effects!
    end

    def resolve_stack!
      return if @stack.empty?
      if pending_effects?
        logger.debug "Pending effects, pausing stack resolution."
        return
      end

      item = @stack.shift
      if item.countered?
        item.countered!
      else
        logger.debug "Resolving #{item.name}"
        item.resolve!
      end

      resolve_effects!

      resolve_stack!
    end

    def unresolved_effects
      effects.reject { _1.resolved? }
    end


    def resolve_effects!
      resolvable_effects_with_targets = effects.unresolved.targeted
      resolvable_effects_with_targets.each do |effect|
        effect.targets.each do |target|
          effect.resolve(target)
        end
      end

      no_choice_effects = unresolved_effects.select { |effect| effect.no_choice? }

      no_choice_effects.each do |effect|
        skip_effect(effect)
        logger.debug "#{effect} has no valid choices, skipping."
      end
    end
  end
end
