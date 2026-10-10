module Magic
  module Cards
    ValgavothsLair = Card("Valgavoth's Lair") do
      type T::Enchantment, T::Land
      keywords :hexproof

      enters_tapped
    end

    class ValgavothsLair < Card
      # "As this land enters, choose a color."
      class ColorChoice < Magic::Choice::Color
        def prompt = "Choose a color. Valgavoth's Lair taps for mana of the chosen color."

        def resolve!(color:)
          actor.card.chosen_color = color
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          game.add_choice(ColorChoice.new(actor: actor))
        end
      end

      def etb_triggers = [ETB]

      # "{T}: Add one mana of the chosen color."
      class ManaAbility < Magic::TapManaAbility
        def choices = [source.card.chosen_color].compact
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
