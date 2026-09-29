module Magic
  module Tokens
    # "It's a land with '{T}: Add {C}' and '{1}: This token becomes a 2/2 creature with all
    # creature types until end of turn. It's still a land.'"
    Mutavault = Token.create("Mutavault") do
      type T::Land
      power 0
      toughness 0

      def activated_abilities = [self.class::ManaAbility, self.class::AnimateAbility]
    end

    Mutavault.const_set(:ManaAbility, Class.new(TapManaAbility) do
      choices :colorless
    end)

    Mutavault.const_set(:AnimateAbility, Class.new(ActivatedAbility) do
      costs "{1}"

      def resolve!
        source.become_creature!(power: 2, toughness: 2, types: Magic::Types::Creatures.values)
      end
    end)
  end
end
