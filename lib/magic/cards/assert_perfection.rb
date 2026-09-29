module Magic
  module Cards
    class AssertPerfection < Sorcery
      card_name "Assert Perfection"
      cost generic: 1, green: 1

      def multi_target? = true

      def target_choices
        [battlefield.controlled_by(controller).creatures, battlefield.not_controlled_by(controller).creatures]
      end

      # "Target creature you control gets +1/+0 until end of turn. It deals damage equal to its
      # power to up to one target creature an opponent controls."
      def resolve!(targets:)
        creature, victim = targets
        trigger_effect(:modify_power_toughness, target: creature, power: 1, toughness: 0)
        game.tick! # so the +1/+0 counts towards the damage
        trigger_effect(:deal_damage, target: victim, damage: creature.power) if victim
      end
    end
  end
end
