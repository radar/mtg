module Magic
  module Cards
    MorcantsLoyalist = Creature("Morcant's Loyalist") do
      power 3
      toughness 2
      cost generic: 1, black: 1, green: 1
      creature_type "Elf Warrior"
    end

    class MorcantsLoyalist < Creature
      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        other_creatures "Elf"
      end

      class Choice < Magic::Choice::Targeted
        def choices
          controller.graveyard.cards.by_any_type("Elf").except(actor.card)
        end

        def choice_amount
          1
        end

        def resolve!(target:)
          target.move_to_hand!
        end
      end

      class Death < TriggeredAbility::Death
        def call
          choice = Choice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def death_triggers = [Death]

      def static_abilities = [PowerAndToughnessModification]
    end
  end
end
