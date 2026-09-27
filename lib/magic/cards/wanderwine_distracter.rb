module Magic
  module Cards
    WanderwineDistracter = Creature("Wanderwine Distracter") do
      cost generic: 3, blue: 1
      creature_type("Merfolk Wizard")
      power 4
      toughness 3
    end

    class WanderwineDistracter < Creature
      class BecomesTappedTrigger < TriggeredAbility
        def should_perform?
          event.permanent == actor
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.not_controlled_by(controller).creatures
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:modify_power_toughness, target: target, power: -3, toughness: 0)
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
