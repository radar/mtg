module Magic
  module Cards
    OsseousExhale = Instant("Osseous Exhale") do
      cost generic: 1, white: 1
    end

    class OsseousExhale < Instant
      # You may behold a Dragon as an additional cost to cast this spell.
      def kicker_cost
        @behold_cost ||= Costs::OptionalBehold.new(self, type: "Dragon")
      end

      def target_choices
        battlefield.creatures.select { game.current_turn.attacking?(_1) || game.current_turn.blocking?(_1) }
      end

      def resolve!(target:)
        trigger_effect(:deal_damage, target: target, damage: 5)
        if kicker_cost.paid?
          trigger_effect(:gain_life, target: controller, life: 2)
        end
      end
    end
  end
end
