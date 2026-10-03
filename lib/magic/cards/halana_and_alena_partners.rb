module Magic
  module Cards
    HalanaAndAlenaPartners = Creature("Halana and Alena, Partners") do
      cost generic: 2, red: 1, green: 1
      legendary_creature_type("Human Ranger")
      keywords :reach, :first_strike
      power 2
      toughness 3
    end

    class HalanaAndAlenaPartners < Creature
      class BeginningOfCombatTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            (battlefield.controlled_by(controller).creatures - [actor])
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: actor.power)
            trigger_effect(:grant_keyword, target: target, keyword: :haste)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = super.merge({ Events::BeginningOfCombat => BeginningOfCombatTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
