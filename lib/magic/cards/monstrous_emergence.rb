module Magic
  module Cards
    class MonstrousEmergence < Sorcery
      card_name "Monstrous Emergence"
      cost generic: 1, green: 1

      # "As an additional cost to cast this spell, choose a creature you control or reveal a creature card from your
      # hand." (Beholding a creature, without the mana alternative.)
      def additional_costs = [behold_cost]

      def behold_cost = @behold_cost ||= Costs::Behold.new(self, type: "Creature")

      def single_target?
        true
      end

      def target_choices = battlefield.creatures

      # "Monstrous Emergence deals damage equal to the power of the creature you chose or the card you revealed to
      # target creature."
      def resolve!(target:)
        chosen = behold_cost.beheld
        power = chosen.is_a?(Magic::Permanent) ? chosen.power : chosen.base_power
        deal_damage(power, to: target)
      end
    end
  end
end
