module Magic
  module Effects
    class SearchLibrary < TargetedEffect
      attr_reader :library, :condition, :resolve_action

      def initialize(library:, condition:, resolve_action:, **args)
        @library = library
        @condition = condition
        @resolve_action = resolve_action
        super(**args)
      end

      def choices
        library.cards.select(&condition)
      end

      def resolve(target)
        resolve_action.call(target)
      end
    end
  end
end
