module Magic
  module Cards
    PrayerOfBinding = Enchantment("Prayer of Binding") do
      cost generic: 3, white: 1
      keywords :flash
    end

    class PrayerOfBinding < Enchantment
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.not_controlled_by(controller).nonland
          end

          def choice_amount = 0..1

          def resolve!(target:)
            actor.exile_until_leaves!(target)
            finish
          end

          def decline! = finish

          def finish
            trigger_effect(:gain_life, target: controller, life: 2)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          choice.choices.any? ? game.add_choice(choice) : choice.finish
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
