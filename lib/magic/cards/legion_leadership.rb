module Magic
  module Cards
    # The land back face of Legion Leadership. It has no mana cost.
    LegionStronghold = Card("Legion Stronghold") do
      type "Land"
    end

    class LegionStronghold < Card
      def enters_tapped? = true

      class ManaAbility < Magic::TapManaAbility
        choices :red, :white
      end

      def activated_abilities = [ManaAbility]
    end

    LegionLeadership = Instant("Legion Leadership") do
      cost "{1}{R/W}"
      back_face LegionStronghold
    end

    class LegionLeadership < Instant
      def target_choices = battlefield.creatures

      # "Until end of turn, double target creature's power and it gains first strike."
      def resolve!(target:)
        pump(target, target.power, 0)
        give_keyword(target, :first_strike)
      end
    end
  end
end
