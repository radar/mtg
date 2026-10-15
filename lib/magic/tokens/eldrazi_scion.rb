module Magic
  module Tokens
    # A 1/1 colorless Eldrazi Scion creature token with "Sacrifice this token: Add {C}."
    EldraziScion = Token.create("Eldrazi Scion") do
      creature_type "Eldrazi Scion"
      power 1
      toughness 1

      def activated_abilities = [self.class::ManaAbility]
    end

    EldraziScion.const_set(:ManaAbility, Class.new(ManaAbility) do
      costs "Sacrifice {this}"
      choices :colorless
    end)
  end
end
