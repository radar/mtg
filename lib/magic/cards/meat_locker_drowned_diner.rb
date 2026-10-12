module Magic
  module Cards
    class MeatLockerDrownedDiner < Room
      class MeatLocker < Room::Door
        card_name "Meat Locker"
        cost generic: 2, blue: 1

        class TargetChoice < Magic::Choice::Targeted
          def choices = battlefield.creatures

          def choice_amount = 0..1

          def resolve!(target:)
            trigger_effect(:tap, target: target)
            trigger_effect(:add_counter, counter_type: "stun", target: target, amount: 2)
          end
        end

        # "When you unlock this door, tap up to one target creature and put two stun counters on it."
        class UnlockedTrigger < Room::UnlockTrigger
          def call
            choice = TargetChoice.new(actor: actor)
            game.add_choice(choice) if choice.choices.any?
          end
        end

        def unlock_triggers = [UnlockedTrigger]
      end

      class DrownedDiner < Room::Door
        card_name "Drowned Diner"
        cost generic: 3, blue: 2

        # "When you unlock this door, draw three cards, then discard a card."
        when_unlocked do
          draw_cards(3)
          actor.add_choice(:discard)
        end
      end

      doors MeatLocker, DrownedDiner
    end
  end
end
