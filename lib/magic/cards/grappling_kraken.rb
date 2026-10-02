module Magic
  module Cards
    GrapplingKraken = Creature("Grappling Kraken") do
      cost generic: 4, blue: 2
      creature_type("Kraken")
      power 5
      toughness 6
    end

    class GrapplingKraken < Creature
      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform?
          you?
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.not_controlled_by(controller).creatures
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:tap, target: target)
            trigger_effect(:add_counter, counter_type: "stun", target: target, amount: 1)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::Landfall => LandfallTrigger }
    end
  end
end
