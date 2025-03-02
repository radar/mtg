module Magic
  class Choice
    class SearchLibrary < Choice
      extend TargetNormalizer

      attr_reader :enters_tapped, :to_zone, :choices, :upto
      def initialize(actor:, filter:, enters_tapped: false, upto: 1, to_zone:)
        @upto = upto
        @to_zone = to_zone
        @choices = actor.controller.library.filter(filter)
        super(actor: actor)
        @enters_tapped = enters_tapped
      end

      def resolve!(targets:)
        case to_zone
        when :battlefield
          targets.map do |target|
            target.resolve!(enters_tapped: enters_tapped)
          end
        when :hand
          targets.map do |target|
            target.move_to_hand!
          end
        end.tap { controller.shuffle! }
      end

      normalize_targets :resolve!
    end
  end
end
