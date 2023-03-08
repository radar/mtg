module Magic
  module Cards
    SureStrike = Instant("Sure Strike") do
      cost generic: 1, red: 1
    end

    class SureStrike < Instant
      def target_choices
        battlefield.creatures
      end

      def single_target?
        true
      end

      def resolve!(controller, target:)
          game.add_effect(Effects::ApplyBuff.new(source: self, power: 3, targets: target))
          target.grant_keyword(Keywords::FIRST_STRIKE, until_eot: true)
        end

        super
      end
    end
  end
end
