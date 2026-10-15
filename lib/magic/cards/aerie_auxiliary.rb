module Magic
  module Cards
    AerieAuxiliary = Creature("Aerie Auxiliary") do
      cost generic: 3, white: 1
      creature_type("Bird Soldier")
      keywords :flying
      power 3
      toughness 3
    end

    class AerieAuxiliary < Creature
      # "When this creature enters, support 2." (a +1/+1 counter on each of up to two other target creatures)
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class SupportChoice < Magic::Choice::Targeted
          def choices = battlefield.creatures - [actor]

          def choice_amount = 0..2

          def resolve!(targets:)
            targets = Array(targets)
            raise ArgumentError, "Support 2 targets at most two creatures" if targets.size > 2

            targets.each { add_counter("+1/+1", to: _1) }
          end
        end

        def call
          choice = SupportChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
