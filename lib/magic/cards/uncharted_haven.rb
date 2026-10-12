module Magic
  module Cards
    UnchartedHaven = Card("Uncharted Haven") do
      type T::Land
      enters_tapped
    end

    class UnchartedHaven < Card
      class ColorChoice < Magic::Choice::Color
        def resolve!(color:)
          raise "Invalid color chosen for Uncharted Haven" unless %i[white blue black red green].include?(color)

          actor.card.chosen_color = color
        end
      end

      # As it enters, choose a color.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.add_choice(ColorChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]

      # {T}: Add one mana of the chosen color.
      class ManaAbility < Magic::TapManaAbility
        def choices = [source.card.chosen_color].compact
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
