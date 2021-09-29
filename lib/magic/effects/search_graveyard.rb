module Magic
  module Effects
    class SearchGraveyard
      attr_reader :graveyard, :condition, :resolve_action

      def initialize(graveyard:, condition:, resolve_action:)
        @graveyard = graveyard
        @condition = condition
        @resolve_action = resolve_action
      end

      def use_stack?
        false
      end

      def requires_choices?
        true
      end

      def single_choice?
        choices.count == 1
      end

      def choices
        graveyard.cards.select(&condition)
      end

      def resolve(target:)
        resolve_action.call(target)
      end

      def resolve_single_choice
        resolve_action.call(choices.first)
      end
    end
  end
end
