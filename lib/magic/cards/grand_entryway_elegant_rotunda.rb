module Magic
  module Cards
    class GrandEntrywayElegantRotunda < Room
      class GrandEntryway < Room::Door
        card_name "Grand Entryway"
        cost generic: 1, white: 1

        # "When you unlock this door, create a 1/1 white Glimmer enchantment creature token."
        when_unlocked do
          trigger_effect(:create_token, token_class: GlimmerSeeker::GlimmerToken)
        end
      end

      class ElegantRotunda < Room::Door
        card_name "Elegant Rotunda"
        cost generic: 2, white: 1

        class CountersChoice < Magic::Choice
          def choices
            game.creatures
          end

          def resolve!(targets:)
            raise ArgumentError, "at most two creatures may be chosen" if targets.size > 2

            targets.each { |target| trigger_effect(:add_counter, counter_type: "+1/+1", target: target) }
          end
        end

        # "When you unlock this door, put a +1/+1 counter on each of up to two target creatures."
        class UnlockedTrigger < Room::UnlockTrigger
          def call
            choice = CountersChoice.new(actor: actor)
            game.choices.add(choice) if choice.choices.any?
          end
        end

        def unlock_triggers = [UnlockedTrigger]
      end

      doors GrandEntryway, ElegantRotunda
    end
  end
end
