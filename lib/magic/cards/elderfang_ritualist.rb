module Magic
  module Cards
    ElderfangRitualist = Creature("ElderfangRitualist") do
      creature_type("Elf Cleric")
      cost generic: 2, white: 2
      power 3
      toughness 1
    end

    class ElderfangRitualist < Creature
      class Choice < Choice::SearchGraveyard
        def choices
          controller.graveyard
        end

        def choice_amount
          1
        end

        def resolve!(target:)
          target.move_to_hand!
        end
      end

      class Death < TriggeredAbility::Death
        def perform
          game.add_choice(ElderfangRitualist::Choice.new(actor: actor))
        end
      end

      def death_triggers = [Death]
    end
  end
end
