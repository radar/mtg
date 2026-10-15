module Magic
  module Tokens
    # A 0/1 colorless Eldrazi Spawn creature token with "Sacrifice this token: Add {C}."
    EldraziSpawn = Token.create("Eldrazi Spawn") do
      creature_type "Eldrazi Spawn"
      power 0
      toughness 1

      def activated_abilities = [self.class::ManaAbility]
    end

    EldraziSpawn.const_set(:ManaAbility, Class.new(ManaAbility) do
      costs "Sacrifice {this}"
      choices :colorless
    end)
  end
end
