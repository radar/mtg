module Magic
  module Cards
    class ChargeThrough < Instant
      NAME = "Charge Through"
      COST = { green: 1 }

      def target_choices
        game.battlefield.creatures
      end

      def single_target?
        true
      end

      def resolve!(controller, target:)
        if target.zone == battlefield
          target.grant_keyword(Keywords::TRAMPLE, until_eot: true)
          controller.draw!
        end

        super
      end
    end
  end
end
