module Magic
  module Effects
    class SearchGraveyard < TargetedEffect
      attr_reader :graveyard, :condition, :resolve_action

      def initialize(resolve_action:, **args)
        @resolve_action = resolve_action
        super(**args)
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
