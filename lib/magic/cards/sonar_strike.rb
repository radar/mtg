module Magic
  module Cards
    class SonarStrike < Instant
      card_name "Sonar Strike"
      cost generic: 1, white: 1

      def target_choices
        combat = game.current_turn.combat
        battlefield.creatures.select { _1.tapped? || combat.attacking?(_1) || combat.blocking?(_1) }
      end

      # Sonar Strike deals 4 damage to target attacking, blocking, or tapped creature. You gain 3 life if
      # you control a Bat.
      def resolve!(target:)
        trigger_effect(:deal_damage, target: target, damage: 4)
        gain_life(3) if battlefield.controlled_by(controller).creatures.any? { _1.type?("Bat") }
      end
    end
  end
end
