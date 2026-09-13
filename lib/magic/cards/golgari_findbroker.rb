module Magic
  module Cards
    GolgariFindbroker = Creature("Golgari Findbroker") do
      cost "{B}{B}{G}{G}"
      creature_type "Elf Shaman"
      power 3
      toughness 4
    end

    class GolgariFindbroker < Creature
      class ReturnChoice < Magic::Choice::Targeted
        def choices
          controller.graveyard.cards.permanents
        end

        def choice_amount
          1
        end

        def resolve!(target:)
          target.move_to_hand!
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          choice = ReturnChoice.new(actor: actor)
          game.choices.add(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
