module Magic
  module Cards
    ThrivingHeath = Card("Thriving Heath") do
      type T::Land

      enters_tapped
    end

    class ThrivingHeath < Card
      class ColorChoice < Magic::Choice::Color
        COLORS = %i[blue black red green]

        def resolve!(color:)
          raise "Invalid color chosen for Thriving Heath" unless COLORS.include?(color)

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
          [:white, source.card.chosen_color].compact
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
