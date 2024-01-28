module Magic
  module Cards
    TempleOfTriumph = Card("Temple of Triumph") do
      type "Land"

      enters_the_battlefield do
        game.add_choice(Choice::Scry.new(source: source))
      end
    end

    class TempleOfTriumph < Card
      def enters_tapped?
        true
      end

      class ManaAbility < Magic::TapManaAbility
        choices :red, :white
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
