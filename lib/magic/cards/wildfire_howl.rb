module Magic
  module Cards
    class WildfireHowl < Sorcery
      card_name "Wildfire Howl"
      cost generic: 1, red: 2
      gift :card

      def target_choices = gift_promised? ? game.any_target : []

      # Wildfire Howl deals 2 damage to each creature. If the gift was promised, instead it deals
      # 1 damage to any target and 2 damage to each creature.
      def resolve!(target: nil)
        deal_damage(1, to: target) if gift_promised? && target
        battlefield.creatures.each { deal_damage(2, to: _1) }
      end
    end
  end
end
