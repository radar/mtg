module Magic
  module Cards
    DunlandCrebain = Creature("Dunland Crebain") do
      cost generic: 2, black: 1
      creature_type "Bird Horror"
      power 1
      toughness 1
      keywords :flying

      enters_the_battlefield do
        Magic::Amass.call(source: actor, controller: controller, amount: 2, subtype: "Orc")
      end
    end
  end
end
