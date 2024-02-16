module Magic
  module Cards
    TranquilCove = Card("Tranquil Cove") do
      type "Land"

      enters_the_battlefield do
        actor.trigger_effect(:gain_life, life: 1)
      end
    end

    class TranquilCove < Card
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
