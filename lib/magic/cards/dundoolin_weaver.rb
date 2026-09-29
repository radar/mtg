module Magic
  module Cards
    DundoolinWeaver = Creature("Dundoolin Weaver") do
      cost generic: 1, green: 1
      creature_type("Kithkin Druid")
      power 2
      toughness 1
    end

    class DundoolinWeaver < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          super && (controller.creatures.count >= 3)
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            controller.graveyard.cards.select(&:permanent?)
          end

          def choice_amount = 1

          def resolve!(target:)
            target.move_to_hand!
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
