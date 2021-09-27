module Magic
  module Effects
    class SearchLibrary
      attr_reader :resolve_action

      def initialize(library:, condition:, resolve_action:)
        @library = library
        @condition = condition
        @resolve_action = resolve_action
      end

      def use_stack?
        false
      end

      def requires_choices?
        true
      end

      def choices
        library.cards.select(condition)
      end

      def resolve(card)
        resolve_action.call(card)
      end
    end
  end
end
