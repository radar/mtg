module Magic
  module Cards
    BlossomingSands = Card("Blossoming Sands") do
      type "Land"

      enters_the_battlefield do
        actor.trigger_effect(:gain_life, life: 1)
      end
    end

    class BlossomingSands < Card
      def enters_tapped?
        true
      end

      class ManaAbility < Magic::TapManaAbility
        choices :green, :white
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
