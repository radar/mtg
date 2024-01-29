module Magic
  module Cards
    TempleOfMystery = Card("Temple of Mystery") do
      type "Land"

      enters_the_battlefield do
        game.add_choice(Choice::Scry.new(source: source))
      end
    end

    class TempleOfMystery < Card
      def enters_tapped?
        true
      end

      class ManaAbility < Magic::TapManaAbility
        choices :blue, :green
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
