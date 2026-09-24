module Magic
  module Tokens
    # "{T}, Sacrifice this artifact: Add one mana of any color."
    Treasure = Token.create("Treasure") do
      type T::Artifact, "Treasure"
      power 0
      toughness 0

      def activated_abilities = [self.class::ManaAbility]
    end

    Treasure.const_set(:ManaAbility, Class.new(ManaAbility) do
      costs "{T}, Sacrifice {this}"
      choices :all
    end)
  end
end
