module Magic
  module Cards
    class BetrayersBargain < Instant
      card_name "Betrayer's Bargain"
      cost generic: 1, red: 1

      # "As an additional cost to cast this spell, sacrifice a creature or enchantment or pay {2}."
      def additional_costs
        [Costs::SacrificeOrMana.new(self, types: ["Creature", "Enchantment"], mana_cost: { generic: 2 })]
      end

      def single_target?
        true
      end

      def target_choices = battlefield.creatures

      # "Betrayer's Bargain deals 5 damage to target creature. If that creature would die this turn, exile it instead."
      def resolve!(target:)
        trigger_effect(:deal_damage, target: target, damage: 5)
        target.register_turn_replacement(Magic::Effects::MovePermanentZone, Magic::ReplacementEffect::ExileInsteadOfDying)
      end
    end
  end
end
