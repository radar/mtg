module Magic
  module Cards
    GoblinTownFlunkies = Creature("Goblin-town Flunkies") do
      cost generic: 1, red: 1
      creature_type "Goblin Soldier"
      power 1
      toughness 1
      keywords :haste

      enters_the_battlefield do
        Magic::Amass.call(source: actor, controller: controller, amount: 1)
      end
    end
  end
end
