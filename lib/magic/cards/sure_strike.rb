module Magic
  module Cards
    SureStrike = Instant("Sure Strike") do
      cost generic: 1, red: 1

      def single_target?
        true
      end

      def target_choices
        battlefield.creatures
      end

      def resolve!(controller, target:)
        game.add_effect(Effects::ApplyPowerToughnessModification.new(source: self, power: 3, targets: target))
        target.grant_keyword(Keywords::FIRST_STRIKE, until_eot: true)
      end
    end
  end
end
