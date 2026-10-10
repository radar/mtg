module Magic
  module Cards
    SaviorOfTheSmall = Creature("Savior of the Small") do
      cost generic: 3, white: 1
      creature_type "Kor Survivor"
      power 3
      toughness 4
    end

    class SaviorOfTheSmall < Creature
      # "Survival — At the beginning of your second main phase, if this creature is tapped, return target creature card
      # with mana value 3 or less from your graveyard to your hand."
      class SurvivalTrigger < TriggeredAbility
        class ReturnChoice < Magic::Choice::Targeted
          def choices = controller.graveyard.cards.select { _1.creature? && _1.mana_value <= 3 }

          def choice_amount = 1

          def resolve!(target:)
            target.move_to_hand!
          end
        end

        def should_perform?
          event.active_player == controller && actor.tapped?
        end

        def call
          choice = ReturnChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::SecondMainPhase => SurvivalTrigger }
    end
  end
end
