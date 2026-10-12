module Magic
  module Cards
    ForebodingRuins = Card("Foreboding Ruins") { type "Land" }

    class ForebodingRuins < Card
      # "As this land enters, you may reveal a Swamp or Mountain card from your hand. If you don't, this land enters
      # tapped." You always reveal one if you have one, since declining is never better.
      def enters_tapped?
        revealable = owner.hand.cards.find { _1.any_type?("Swamp", "Mountain") }
        revealable&.reveal!
        revealable.nil?
      end

      class ManaAbility < Magic::TapManaAbility
        choices :black, :red
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
