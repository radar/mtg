module Magic
  module Cards
    TempleOfSilence = Card("Temple of Silence") do
      type "Land"

      enters_the_battlefield do
        game.add_choice(Choice::Scry.new(source: source))
      end
    end

    class TempleOfSilence < Card
      def enters_tapped?
        true
      end

      class ManaAbility < Magic::TapManaAbility
        choices :white, :black
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
