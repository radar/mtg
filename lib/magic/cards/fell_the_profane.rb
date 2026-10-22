module Magic
  module Cards
    # The land back face of Fell the Profane. It has no mana cost.
    FellMire = Card("Fell Mire") do
      type "Land"
    end

    class FellMire < Card
      # "As this land enters, you may pay 3 life. If you don't, it enters tapped." Answered by
      # `p1.play_land(land: card, face: :back, pay_life: true)`.
      def shock_life = 3

      class ManaAbility < Magic::TapManaAbility
        choices :black
      end

      def activated_abilities = [ManaAbility]
    end

    FellTheProfane = Instant("Fell the Profane") do
      cost generic: 2, black: 2
      back_face FellMire
    end

    class FellTheProfane < Instant
      def target_choices = battlefield.creatures + battlefield.planeswalkers

      def resolve!(target:)
        destroy(target)
      end
    end
  end
end
