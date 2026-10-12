module Magic
  module Cards
    TempleOfEnlightenment = Card("Temple of Enlightenment") do
      type "Land"

      enters_the_battlefield do
        game.add_choice(Choice::Scry.new(actor: actor))
      end
    end

    class TempleOfEnlightenment < Card
      def enters_tapped?
        true
      end

      class ManaAbility < Magic::TapManaAbility
        choices :white, :blue
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
