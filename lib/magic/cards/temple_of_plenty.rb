module Magic
  module Cards
    TempleOfPlenty = Card("Temple of Plenty") do
      type "Land"

      enters_the_battlefield do
        game.add_choice(Choice::Scry.new(actor: actor))
      end
    end

    class TempleOfPlenty < Card
      def enters_tapped? = true

      class ManaAbility < Magic::TapManaAbility
        choices :green, :white
      end

      def activated_abilities = [ManaAbility]
    end
  end
end