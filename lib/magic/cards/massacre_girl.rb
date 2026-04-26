module Magic
  module Cards
    class MassacreGirl < Creature
      card_name "Massacre Girl"
      legendary_creature_type "Human Assassin"
      cost generic: 3, black: 2
      power 4
      toughness 4
      keywords :menace

      class ETBTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          actor.register_turn_trigger(Events::CreatureDied, CreatureDiedTrigger)
          debuff!
        end

        private

        def debuff!
          game.creatures.except(actor).each do |creature|
            trigger_effect(:modify_power_toughness, target: creature, power: -1, toughness: -1)
          end
        end
      end

      class CreatureDiedTrigger < TriggeredAbility
        def call
          game.creatures.except(actor).each do |creature|
            trigger_effect(:modify_power_toughness, target: creature, power: -1, toughness: -1)
          end
        end
      end

      def etb_triggers = [ETBTrigger]
    end
  end
end
