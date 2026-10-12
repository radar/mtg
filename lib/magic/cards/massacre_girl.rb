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
            pump(creature, -1, -1)
          end
        end
      end

      class CreatureDiedTrigger < TriggeredAbility
        def call
          game.creatures.except(actor).each do |creature|
            pump(creature, -1, -1)
          end
        end
      end

      def etb_triggers = [ETBTrigger]
    end
  end
end
