module Magic
  module Cards
    MangaraTheDiplomat = Creature("Mangara, the Diplomat") do
      cost generic: 3, white: 1
      type "Legendary Creature - Human Cleric"
      power 2
      toughness 4
      keywords :lifelink

      def receive_notification(event)
        case event
        when Events::AttackersDeclared
          incoming_attacks = event.attacks.select do |attack|
            attack.target == controller ||
            (attack.target.planeswalker? || attack.target.controller == controller)
          end
          controller.draw! if incoming_attacks.count >= 2
        when Events::SpellCast
          spells_cast_by_player = current_turn.spells_cast.count { |spell| spell.player == event.player }
          controller.draw! if spells_cast_by_player == 2
        end
      end
    end
  end
end
