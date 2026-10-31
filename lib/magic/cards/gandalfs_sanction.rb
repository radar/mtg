module Magic
  module Cards
    GandalfsSanction = Sorcery("Gandalf's Sanction") do
      cost "{1}{U}{R}"
    end

    class GandalfsSanction < Sorcery
      def target_choices = battlefield.creatures

      # "...deals X damage to target creature, where X is the number of instant and sorcery cards in your graveyard.
      # Excess damage is dealt to that creature's controller instead." Only lethal damage (toughness minus damage
      # already marked) is dealt to the creature; the rest goes to its controller.
      def resolve!(target:)
        x = controller.graveyard.cards.count { _1.type?("Instant") || _1.type?("Sorcery") }
        lethal = [target.toughness - target.damage, 0].max
        to_creature = [x, lethal].min
        excess = x - to_creature
        deal_damage(to_creature, to: target) if to_creature.positive?
        deal_damage(excess, to: target.controller) if excess.positive?
        super()
      end
    end
  end
end
