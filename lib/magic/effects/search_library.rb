module Magic
  module Effects
    class SearchLibrary < Effect
      attr_reader :library, :condition, :resolve_action

      def initialize(library:, condition:, resolve_action:)
        @library = library
        @condition = condition
        @resolve_action = resolve_action
        super()
      end

      def requires_choices?
        true
      end

      def single_choice?
        choices.count == 1
      end

      def choices
        library.cards.select(&condition)
      end

      def resolve(target:)
        resolve_action.call(target)
      end
    end
  end
end
