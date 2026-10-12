module Magic
  module Cards
    class SlaveringBranchsnapper < Creature
      card_name "Slavering Branchsnapper"
      cost generic: 4, green: 2
      creature_type "Lizard"
      power 7
      toughness 6
      keywords :trample
      # "Forestcycling {2}"
      landcycling({ generic: 2 }, filter: "Forest")
    end
  end
end
