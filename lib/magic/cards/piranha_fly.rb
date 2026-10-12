module Magic
  module Cards
    PiranhaFly = Creature("Piranha Fly") do
      cost generic: 1, blue: 1
      creature_type("Fish Insect")
      keywords :flying
      power 2
      toughness 1
    end

    class PiranhaFly < Creature
      enters_tapped
    end
  end
end
