module Magic
  module Cards
    ThrivingBluff = Card("Thriving Bluff") do
      type T::Land

      enters_tapped
    end

    class ThrivingBluff < Card
      class ColorChoice < Magic::Choice::Color
        COLORS = %i[white blue black green]

        def prompt = "Choose a color other than red. Thriving Bluff taps for red or the chosen color."

        def resolve!(color:)
          raise "Invalid color chosen for Thriving Bluff" unless COLORS.include?(color)

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
          [:red, source.card.chosen_color].compact
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
