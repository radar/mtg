module Magic
  module Effects
    class AddCounter
      attr_reader :power, :toughness, :targets, :choices

      def initialize(power: 1, toughness: 1, targets: 1, choices:)
        @power = power
        @toughness = toughness
        @targets = targets
        @choices = choices
      end

      def multiple_targets?
        targets > 1
      end

      def requires_choices?
        true
      end

      def single_choice?
        choices.count == 1
      end

      def resolve(targets:)
        targets.each do |target|
          target.add_counter(power: power, toughness: toughness)
        end
      end
    end
  end
end
