module Magic
  module Cards
    FeatOfResistance = Instant("Feat of Resistance") do
      cost generic: 1, white: 1
    end

    class FeatOfResistance < Instant
      def single_target?
        true
      end

      def target_choices(controller)
        controller.creatures
      end

      class Choice < Magic::Choice::Color
        attr_reader :target
        def initialize(source:, target:)
          super(source: source)
          @target = target
        end

        def resolve!(color:)
          target.gains_protection_from_color(color, until_eot: true)
        end
      end

      def resolve!(target:)
        target.add_counter(Counters::Plus1Plus1)
        game.choices.add(Choice.new(source: self, target: target))
      end
    end
  end
end
