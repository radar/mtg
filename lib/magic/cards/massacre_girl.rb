module Magic
  module Cards
    class MassacreGirl < Creature
      card_name "Massacre Girl"
      legendary_creature_type "Human Assassin"
      cost generic: 3, black: 2
      power 4
      toughness 4
      keywords :menace

      class CreatureDiedDebuff < TriggeredAbility
        def call
          game.creatures.except(actor).each do |creature|
            trigger_effect(:modify_power_toughness, target: creature, power: -1, toughness: -1)
          end
        end
      end

      enters_the_battlefield do
        game.creatures.except(actor).each do |creature|
          actor.trigger_effect(:modify_power_toughness, target: creature, power: -1, toughness: -1)
        end
        actor.register_until_eot_handler(Events::CreatureDied, CreatureDiedDebuff)
      end
    end
  end
end
