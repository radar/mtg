module Magic
  module Cards
    ExplosiveProdigy = Creature("Explosive Prodigy") do
      creature_type "Elemental Sorcerer"
      cost generic: 1, red: 1
      power 1
      toughness 1
    end

    class ExplosiveProdigy < Creature
      class TargetChoice < Magic::Choice::Targeted
        def choices
          battlefield.creatures.not_controlled_by(controller)
        end

        def choice_amount = 1

        # Vivid -- X is the number of colors among permanents you control.
        def resolve!(target:)
          trigger_effect(:deal_damage, damage: controller.colors_among_permanents, target: target)
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
