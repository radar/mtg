module Magic
  module Effects
    class SearchGraveyard < TargetedEffect
      attr_reader :graveyard, :condition, :resolve_action

      def initialize(graveyard:, condition:, resolve_action:, **args)
        @graveyard = graveyard
        @condition = condition
        @resolve_action = resolve_action
        super(**args)
      end

      def choices
        graveyard.cards.select(&condition)
      end

      def resolve(target)
        resolve_action.call(target)
      end

      def resolve_single_choice
        resolve_action.call(choices.first)
      end
    end
  end
end
