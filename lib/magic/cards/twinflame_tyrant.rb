module Magic
  module Cards
    TwinflameTyrant = Creature("Twinflame Tyrant") do
      cost generic: 3, red: 2
      creature_type("Dragon")
      keywords :flying
      power 3
      toughness 5
    end

    class TwinflameTyrant < Creature
      def replacement_effects = ReplacementEffect::OpponentDamageDoubler.registrations
    end
  end
end
