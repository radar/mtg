module Magic
  module Cards
    RoamingGhostlight = Creature("Roaming Ghostlight") do
      cost generic: 3, blue: 2
      type "Creature -- Spirit"
      power 3
      toughness 2
      keywords :flying

      enters_the_battlefield do
        choices = game.battlefield.creatures.excluding_type(T::Creatures['Spirit'])
        game.add_effect(Effects::ReturnToOwnersHand.new(source: self, choices: choices))
      end
    end
  end
end
