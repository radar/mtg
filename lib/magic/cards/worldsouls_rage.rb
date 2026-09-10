module Magic
  module Cards
    class WorldsoulsRage < Sorcery
      card_name "Worldsoul's Rage"
      cost x: 1, red: 1, green: 1

      def target_choices
        game.any_target
      end

      def resolve!(target:, value_for_x:)
        trigger_effect(:deal_damage, target: target, damage: value_for_x)
        lands = (controller.hand.lands + controller.graveyard.lands).first(value_for_x)
        lands.each { |land| land.resolve!(enters_tapped: true) }
      end
    end
  end
end
