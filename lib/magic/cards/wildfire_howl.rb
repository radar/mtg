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
        trigger_effect(:deal_damage, target: target, damage: 1) if gift_promised? && target
        battlefield.creatures.each { trigger_effect(:deal_damage, target: _1, damage: 2) }
      end
    end
  end
end
