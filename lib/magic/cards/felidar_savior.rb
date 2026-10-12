module Magic
  module Cards
    FelidarSavior = Creature("Felidar Savior") do
      cost generic: 3, white: 1
      creature_type("Cat Beast")
      keywords :lifelink
      power 2
      toughness 3
    end

    class FelidarSavior < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            (battlefield.controlled_by(controller).creatures - [actor])
          end

          def choice_amount = 0..2

          def resolve!(targets:)
            targets.each { add_counter("+1/+1", to: _1) }
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
