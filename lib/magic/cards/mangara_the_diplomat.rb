module Magic
  module Cards
    MangaraTheDiplomat = Creature("Mangara, the Diplomat") do
      cost generic: 3, white: 1
      type T::Super::Legendary, T::Creature, *creature_types("Human Cleric")
      power 2
      toughness 4
      keywords :lifelink
    end

    class MangaraTheDiplomat < Creature
      class FinalAttackersDeclaredTrigger < TriggeredAbility
        def should_perform?
          controller = actor.controller
          incoming_attacks = event.attacks.select do |attack|
            attack.target == controller ||
            controller.planeswalkers.any? { |planeswalker| attack.target == planeswalker }
          end

          incoming_attacks.count >= 2
        end

        def call
          actor.controller.draw!
        end
      end

      class SpellCastTrigger < TriggeredAbility
        def should_perform?
          spells_cast_by_player = game.current_turn.spells_cast.count { |spell| spell.player == event.player && !you? }
          spells_cast_by_player == 2
        end

        def call
          actor.controller.draw!
        end
      end

      def event_handlers
        {
          # Whenever an opponent attacks with creatures, if two or more of those creatures are
          # attacking you and/or planeswalkers you control, draw a card.
          Events::FinalAttackersDeclared => FinalAttackersDeclaredTrigger,
          Events::SpellCast => SpellCastTrigger,
        }
      end
    end
  end
end
