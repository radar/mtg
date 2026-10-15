module Magic
  module Cards
    # The land back face of a spell // land modal double-faced card. It has no mana cost.
    OldGrowthGrove = Card("Old-Growth Grove") do
      type "Land"
    end

    class OldGrowthGrove < Card
      def enters_tapped? = true

      class ManaAbility < Magic::TapManaAbility
        choices :black, :green
      end

      def activated_abilities = [ManaAbility]
    end

    RevitalizingRepast = Instant("Revitalizing Repast") do
      cost black_or_green: 1
      back_face OldGrowthGrove
    end

    class RevitalizingRepast < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        add_counter("+1/+1", to: target)
        give_keyword(target, :indestructible)
      end
    end
  end
end
