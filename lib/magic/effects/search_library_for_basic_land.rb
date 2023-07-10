module Magic
  module Effects
    class SearchLibraryForBasicLand < TargetedEffect
      attr_reader :enters_tapped
      def initialize(source:, enters_tapped: false)
        super(source: source, choices: source.controller.library.basic_lands)
        @enters_tapped = enters_tapped
      end

      def resolve(target)
        permanent = target.resolve!(source.controller, enters_tapped: enters_tapped)
        source.controller.shuffle!
        permanent
      end
    end
  end
end
