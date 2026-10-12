module Magic
  module Cards
    class SurgicalSuiteHospitalRoom < Room
      class SurgicalSuite < Room::Door
        card_name "Surgical Suite"
        cost generic: 1, white: 1

        class ReturnChoice < Magic::Choice::Targeted
          def choices = controller.graveyard.cards.select { _1.creature? && _1.mana_value <= 3 }

          def choice_amount = 1

          def resolve!(target:)
            Permanent.put_onto_battlefield(game: game, card: target, from_zone: target.zone, controller: controller)
          end
        end

        # "When you unlock this door, return target creature card with mana value 3 or less from your graveyard to the
        # battlefield."
        class UnlockedTrigger < Room::UnlockTrigger
          def call
            choice = ReturnChoice.new(actor: actor)
            game.add_choice(choice) if choice.choices.any?
          end
        end

        def unlock_triggers = [UnlockedTrigger]
      end

      class HospitalRoom < Room::Door
        card_name "Hospital Room"
        cost generic: 3, white: 1

        class CounterChoice < Magic::Choice::Targeted
          def initialize(actor:, attackers:)
            super(actor: actor)
            @attackers = attackers
          end

          def choices = @attackers

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:add_counter, counter_type: "+1/+1", target: target)
          end
        end

        # "Whenever you attack, put a +1/+1 counter on target attacking creature."
        class AttackTrigger < TriggeredAbility
          def should_perform? = event.active_player == controller && event.attacks.any?

          def call
            game.add_choice(CounterChoice.new(actor: actor, attackers: event.attacks.map(&:attacker)))
          end
        end

        def event_handlers = { Events::FinalAttackersDeclared => AttackTrigger }
      end

      doors SurgicalSuite, HospitalRoom
    end
  end
end
