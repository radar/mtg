module Magic
  module Cards
    WildJhovall = Creature("Wild Jhovall") do
      cost generic: 3, red: 1
      creature_type("Cat")
      power 3
      toughness 3
    end
  end
end