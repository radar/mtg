module Magic
  module Cards
    TempleOfEpiphany = Card("Temple of Epiphany") do
      type "Land"

      enters_the_battlefield do
        game.add_choice(Choice::Scry.new(actor: actor))
      end
    end

    class TempleOfEpiphany < Card
      def enters_tapped?
        true
      end

      class ManaAbility < Magic::TapManaAbility
        choices :blue, :red
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
