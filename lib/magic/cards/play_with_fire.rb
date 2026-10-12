module Magic
  module Cards
    class PlayWithFire < Instant
      NAME = "Play with Fire"
      COST = { red: 1 }

      def target_choices
        game.any_target
      end

      def resolve!(target:)
        deal_damage(2, to: target)

        game.choices.add(Magic::Choice::Scry.new(actor: self, amount: 1)) if target.is_a?(Player)
      end
    end
  end
end
