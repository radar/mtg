module Magic
  module Cards
    BrambleguardCaptain = Creature("Brambleguard Captain") do
      cost generic: 3, red: 1
      creature_type("Mouse Soldier")
      power 2
      toughness 3
    end

    class BrambleguardCaptain < Creature
      class BeginningOfCombatTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.controlled_by(controller).creatures
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:modify_power_toughness, target: target, power: actor.power, toughness: 0)
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
