module Magic
  module Cards
    class RimefireTorque < Artifact
      card_name "Rimefire Torque"
      cost generic: 1, blue: 1

      class ChooseTypeChoice < Magic::Choice::ChooseCreatureTypeForPermanent
      end

      # "As this artifact enters, choose a creature type."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(ChooseTypeChoice.new(actor:))
        end
      end

      # "Whenever a permanent you control of the chosen type enters, put a charge counter on this
      # artifact."
      class ChosenTypeEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          type = actor.chosen_creature_type
          !type.nil? && event.permanent.controller == controller && event.permanent.type?(type)
        end

        def call
          trigger_effect(:add_counter, counter_type: "charge", target: actor)
        end
      end

      # "When you next cast an instant or sorcery spell this turn, copy it. You may choose new
      # targets for the copy." (One shot: it marks itself used as it triggers.)
      class CopyNextSpellTrigger < TriggeredAbility::SpellCast
        KEY = :rimefire_torque_copy

        def should_perform?
          return false unless you? && (spell.instant? || spell.sorcery?) && !actor.triggered_once_this_turn?(KEY)

          actor.trigger_once_this_turn!(KEY)
          true
        end

        def call
          Magic::CopyEffect.resolve_with_choice!(actor: spell, receiver: spell, targets: event.targets, copies: 1)
        end
      end

      # "{T}, Remove three charge counters from this artifact: When you next cast an instant or
      # sorcery spell this turn, copy it."
      class CopyAbility < Magic::ActivatedAbility
        costs "{T}, Remove 3 charge counters from {this}"

        def resolve!
          source.register_turn_trigger(Events::SpellCast, CopyNextSpellTrigger)
        end
      end

      def etb_triggers = [EntersTrigger]

      def activated_abilities = [CopyAbility]

      def event_handlers = { Events::EnteredTheBattlefield => ChosenTypeEntersTrigger }
    end
  end
end
