module Magic
  module Cards
    MoraugFuryOfAkoum = Creature("Moraug, Fury of Akoum") do
      legendary_creature_type "Minotaur Warrior"
      cost generic: 4, red: 2
      power 6
      toughness 6
    end

    class MoraugFuryOfAkoum < Creature
      class AttackPowerModification < Abilities::Static::PowerAndToughnessModification
        def applicable_targets
          source.controller.creatures
        end

        def power_modification
          source.game.current_turn.events.count do |event|
            event.is_a?(Events::AttackDeclared) && event.attack.attacker == source
          end
        end

        def toughness_modification = 0
      end

      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform?
          event.player == controller && game.current_turn.step?(:first_main)
        end

        def call
          game.current_turn.queue_additional_combat!
        end
      end

      def static_abilities = [AttackPowerModification]

      def event_handlers
        { Events::Landfall => LandfallTrigger }
      end
    end
  end
end