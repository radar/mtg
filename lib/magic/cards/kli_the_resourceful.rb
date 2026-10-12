module Magic
  module Cards
    KliTheResourceful = Creature("Kíli the Resourceful") do
      legendary_creature_type "Dwarf Scout"
      cost generic: 1, white: 1
      power 1
      toughness 2
    end

    class KliTheResourceful < Creature
      # Storied (see Magic::Storied). "As long as you have an enduring story, you may pay {0} rather than pay the equip
      # cost of the first equip ability you activate each turn." Answered as a cost reduction once the targets are known
      # (see Actions::ActivateAbility#apply_target_cost_reductions!): the whole generic cost comes off.
      class FirstEquipFree < StaticAbility
        def activation_cost_reduction_for_targets(ability, _targets, player)
          return 0 unless player == controller && ability.respond_to?(:equip?) && ability.equip?
          return 0 unless Magic::Storied.enduring_story?(controller)

          earlier_equips = game.current_turn.events.count do |event|
            event.is_a?(Events::AbilityActivated) && event.player == player && event.ability.respond_to?(:equip?) && event.ability.equip?
          end
          earlier_equips.zero? ? 100 : 0
        end
      end

      # "Whenever another Dwarf or Equipment you control enters, draw a card. This ability triggers only once each turn."
      class EntersTrigger < TriggeredAbility
        def should_perform?
          Magic::Storied.check(controller)
          permanent = event.permanent
          permanent != actor && permanent.controller == controller && (permanent.type?("Dwarf") || permanent.type?("Equipment")) &&
            !actor.triggered_once_this_turn?(self.class)
        end

        def trigger!
          return false unless should_perform?

          actor.trigger_once_this_turn!(self.class)
          true
        end

        def call
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      def static_abilities = [FirstEquipFree]

      def event_handlers
        super.merge({ Events::EnteredTheBattlefield => EntersTrigger }) { |_, old, new| [*old, *new] }
      end
    end
  end
end
