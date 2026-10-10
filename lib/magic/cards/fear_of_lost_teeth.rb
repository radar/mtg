module Magic
  module Cards
    FearOfLostTeeth = Creature("Fear of Lost Teeth") do
      cost black: 1
      enchantment_creature_type("Nightmare")
      power 1
      toughness 1
    end

    class FearOfLostTeeth < Creature
      class DiesTrigger < TriggeredAbility::Death
        class TargetChoice < Magic::Choice::Targeted
          def choices
            game.any_target
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:deal_damage, target: target, damage: 1)
            trigger_effect(:gain_life, target: controller, life: 1)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
