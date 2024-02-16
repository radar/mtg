module Magic
  module Cards
    ScouredBarrens = Card("Scoured Barrens") do
      type "Land"

      enters_the_battlefield do
        actor.trigger_effect(:gain_life, life: 1)
      end
    end

    class ScouredBarrens < Card
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
