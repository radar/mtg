module Magic
  module Cards
    class MassacreGirl < Creature
      card_name "Massacre Girl"
      legendary_creature_type "Human Assassin"
      cost generic: 3, black: 2
      power 4
      toughness 4
      keywords :menace

      attr_accessor :creature_died_active_turn

      class CreatureDiedDebuff < TriggeredAbility
        def should_perform?
          actor.card.creature_died_active_turn == game.current_turn.number
        end

        def call
          game.creatures.except(actor).each do |creature|
            trigger_effect(:modify_power_toughness, target: creature, power: -1, toughness: -1)
          end
        end
      end

      def event_handlers
        {
          Events::CreatureDied => CreatureDiedDebuff
        }
      end

      enters_the_battlefield do
        game.creatures.except(actor).each do |creature|
          actor.trigger_effect(:modify_power_toughness, target: creature, power: -1, toughness: -1)
        end
        actor.card.creature_died_active_turn = game.current_turn.number
      end
    end
  end
end
