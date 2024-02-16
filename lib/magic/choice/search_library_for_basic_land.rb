module Magic
  class Choice
    class SearchLibraryForBasicLand < Choice
      attr_reader :enters_tapped
      def initialize(actor:, enters_tapped: false)
        super(actor: actor)
        @enters_tapped = enters_tapped
      end

      def choices
        controller.library.basic_lands
      end

      def resolve!(target:)
        permanent = target.resolve!(enters_tapped: enters_tapped)
        controller.shuffle!
        permanent
      end
    end
  end
end
