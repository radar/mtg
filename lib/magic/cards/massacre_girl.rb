module Magic
  module Cards
    class MassacreGirl < Creature
      card_name "Massacre Girl"
      legendary_creature_type "Human Assassin"
      cost generic: 3, black: 2
      power 4
      toughness 4
      keywords :menace

      enters_the_battlefield do
        debuff = -> do
          game.creatures.except(actor).each do |creature|
            actor.trigger_effect(:modify_power_toughness, target: creature, power: -1, toughness: -1)
          end
        end

        debuff.call

        actor.delayed_response(
          turn: game.current_turn,
          event_type: Events::CreatureDied,
          response: debuff,
        )
      end
    end
  end
end
