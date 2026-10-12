module Magic
  module Cards
    SplashLasher = Creature("Splash Lasher") do
      cost generic: 3, blue: 1
      creature_type("Frog Wizard")
      power 3
      toughness 3
      offspring generic: 1, blue: 1
    end

    class SplashLasher < Creature
      # When this creature enters, tap up to one target creature and put a stun counter on it.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TapChoice < Magic::Choice::Targeted
          def choices = battlefield.creatures

          def choice_amount = 0..1

          def resolve!(target:)
            trigger_effect(:tap, target: target)
            trigger_effect(:add_counter, counter_type: "stun", target: target, amount: 1)
          end
        end

        def call
          choice = TapChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
