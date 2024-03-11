module Magic
  class Stack
    extend Forwardable

    def_delegators :@stack, :first, :select, :count, :include?, :map, :empty?

    attr_reader :logger, :effects, :choices

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

    def initialize(logger: Logger.new($stdout), stack: [], effects: [], choices: [])
      @logger = logger
      @stack = stack
      @effects = Effects.new(effects)
      @choices = Choices.new(choices)
    end

    def add(item)
      logger.debug "Item added to stack: #{item}"
      @stack.unshift(item)
    end

    def remove(target)
      @stack.delete(target)
    end

    def exile!
      @stack.each(&:exile!)
      @stack.clear
    end

    def counter!(target)
      remove(target)
      target.countered!
    end

    def spells
      @stack.select { |item| item.is_a?(Magic::Actions::Cast) }
    end

    def abilities
      @stack.select { |item| item.is_a?(Magic::Actions::ActivateAbility) || item.is_a?(TriggeredAbility) }
    end

    def cards
      @stack.map do |item|
        item.respond_to?(:card) ? item.card : item
      end
    end

    def add_choice(choice)
      logger.debug "Choice added: #{choice}"
      @choices.add(choice)

      if choice.is_a?(Magic::Choice::Targeted)
        if choice.single_target? && choice.single_choice?
          logger.debug "  Only one valid target for choice, resolving choice immediately."
          resolve_choice!(target: choice.target_choices.first)
        end
      end
    end

    def pending_choices?
      @choices.any?
    end

    def resolve!
      logger.debug "Resolving stack."
      resolve_stack!
      resolve_effects!
    end

    def resolve_stack!
      return if @stack.empty?
      if pending_choices?
        logger.debug "Pending choices, pausing stack resolution."
        return
      end

      item = @stack.shift
      logger.debug "Resolving #{item.name}"
      item.resolve!

      resolve_effects!

      resolve_stack!
    end

    def unresolved_effects
      effects.reject { _1.resolved? }
    end

    def resolve_effects!
      resolvable_effects_with_targets = effects.unresolved.targeted
      resolvable_effects_with_targets.each do |effect|
        effects.delete(effect)
        effect.targets.each do |target|
          effect.resolve(target)
        end
      end
    end

    def skip_choice!
      logger.debug "Skipping Choice: #{@choices.first}"
      choices.shift
    end

    def resolve_choice!(**args)
      choice = choices.shift
      choice.resolve!(**args)
    end
  end
end
