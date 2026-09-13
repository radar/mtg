module Magic
  module Cards
    class PlayWithFire < Instant
      NAME = "Play with Fire"
      COST = { red: 1 }

      def target_choices
        game.any_target
      end

      def resolve!(target:)
        trigger_effect(:deal_damage, target: target, damage: 2)

        game.choices.add(Magic::Choice::Scry.new(actor: self, amount: 1)) if target.is_a?(Player)
      end
    end
  end
end
