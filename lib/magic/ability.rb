module Magic
  class Ability
    include BattlefieldFilters

    attr_reader :source

    def initialize(source:)
      @source = source
    end

    # A multi-target ability (`multi_target?`) has one list of choices per target.
    def valid_targets?(*targets)
      return targets.each_with_index.all? { |target, index| legal_target?(target, target_choices[index]) } if multi_target?

      targets.all? { legal_target?(_1, target_choices) }
    end

    # In the ability's choices, and not shroud/hexproof/protected against its source.
    def legal_target?(target, choices)
      !choices.nil? && choices.include?(target) && Targetable.targetable_by?(target, source: source, controller: controller)
    end

    def multi_target? = false

    def trigger_effect(effect, **args)
      source.trigger_effect(effect, source: self, **args)
    end

    def add_choice(choice, **args)
      source.add_choice(choice, **args)
    end

    def game
      source.game
    end

    def controller
      source.controller
    end

    def hand
      controller.hand
    end

    def graveyard
      controller.graveyard
    end

    def library
      controller.library
    end
  end
end
