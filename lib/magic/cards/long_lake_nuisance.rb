module Magic
  module Cards
    LongLakeNuisance = Creature("Long Lake Nuisance") do
      cost generic: 3, blue: 1
      creature_type "Bird"
      power 3
      toughness 1
      keywords :flying

      enters_the_battlefield do
        Magic::Recruit.call(player: controller)
      end
    end
  end
end
