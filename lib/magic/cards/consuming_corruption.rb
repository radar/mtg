module Magic
  module Cards
    class ConsumingCorruption < Instant
      card_name "Consuming Corruption"
      cost black: 2

      def target_choices = battlefield.creatures + battlefield.planeswalkers

      # Deals X damage to target creature or planeswalker and you gain X life, where X is the number of Swamps you
      # control.
      def resolve!(target:)
        x = battlefield.controlled_by(controller).count { _1.type?("Swamp") }
        deal_damage(x, to: target)
        gain_life x
      end
    end
  end
end
