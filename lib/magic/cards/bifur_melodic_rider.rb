module Magic
  module Cards
    BifurMelodicRider = Creature("Bifur, Melodic Rider") do
      cost "{4}{R/W}{R/W}"
      legendary_creature_type "Dwarf Bard"
      power 4
      toughness 5
    end

    class BifurMelodicRider < Creature
      # "Whenever Bifur enters or attacks, put a +1/+1 counter on target creature."
      module PutCounter
        class TargetChoice < Magic::Choice::Targeted
          def choices = battlefield.creatures

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 1)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        include PutCounter
      end

      class AttacksTrigger < TriggeredAbility
        include PutCounter

        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end
      end

      # "As long as you have an enduring story, if a triggered ability of a Dwarf you control triggers, that ability
      # triggers an additional time." Bifur is a Dwarf itself, so it doubles its own triggers too.
      class TriggersAdditionalTime < Abilities::Static::TriggeredAbilityDoubler
        def doubles_trigger_for?(permanent, _event)
          permanent.controller == controller && permanent.type?("Dwarf") && Magic::Storied.enduring_story?(controller)
        end
      end

      def etb_triggers = [EntersTrigger]

      def static_abilities = [TriggersAdditionalTime]

      def event_handlers = super.merge(Events::FinalAttackersDeclared => AttacksTrigger)
    end
  end
end
