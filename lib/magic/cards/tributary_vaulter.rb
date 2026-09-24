module Magic
  module Cards
    TributaryVaulter = Creature("Tributary Vaulter") do
      cost generic: 2, white: 1
      creature_type("Merfolk Warrior")
      keywords :flying
      power 1
      toughness 3
    end

    class TributaryVaulter < Creature
      class BecomesTappedTrigger < TriggeredAbility
        def should_perform?
          event.permanent == actor
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            (battlefield.controlled_by(controller).creatures.by_any_type("Merfolk") - [actor])
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:modify_power_toughness, target: target, power: 2, toughness: 0)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::PermanentTapped => BecomesTappedTrigger }
    end
  end
end
