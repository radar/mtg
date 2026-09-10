module Magic
  module Cards
    ThrivingMoor = Card("Thriving Moor") do
      type T::Land

      enters_tapped
    end

    class ThrivingMoor < Card
      class ColorChoice < Magic::Choice::Color
        COLORS = %i[white blue red green]

        def resolve!(color:)
          raise "Invalid color chosen for Thriving Moor" unless COLORS.include?(color)

          actor.card.chosen_color = color
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          game.add_choice(ColorChoice.new(actor: actor))
        end
      end

      def etb_triggers = [ETB]

      class ManaAbility < Magic::TapManaAbility
        def choices
          [:black, source.card.chosen_color]
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
