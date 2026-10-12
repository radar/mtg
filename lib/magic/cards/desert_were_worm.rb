module Magic
  module Cards
    DesertWereWorm = Creature("Desert Were-Worm") do
      cost generic: 4, red: 2
      creature_type "Dragon Wurm"
      power 0
      toughness 5
    end

    class DesertWereWorm < Creature
      # "This creature gets +2/+0 for each Mountain you control."
      class MountainPower < Abilities::Static::PowerAndToughnessModification
        applicable_targets { [source] }

        def power_modification = 2 * source.controller.lands.by_any_type("Mountain").count
      end

      def static_abilities = [MountainPower]

      # "Whenever you attack with creatures with total power 12 or greater for the first time each turn, untap all
      # attacking creatures. After this phase, there is an additional combat phase."
      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && event.attacks.sum { _1.attacker.power } >= 12
        end

        def trigger!
          return false unless should_perform?
          return false if actor.triggered_once_this_turn?(self.class)

          actor.trigger_once_this_turn!(self.class)
          true
        end

        def call
          event.attacks.each { _1.attacker.untap! }
          game.current_turn.queue_additional_combat!
        end
      end

      def event_handlers
        super.merge({ Events::FinalAttackersDeclared => AttackTrigger }) { |_, old, new| [*old, *new] }
      end
    end
  end
end
