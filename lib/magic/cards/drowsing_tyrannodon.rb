module Magic
  module Cards
    DrowsingTyrannodon = Creature("Drowsing Tyrannodon") do
      cost generic: 1, green: 1
      creature_type "Dinosaur"
      keywords :defender
      power 3
      toughness 3
    end

    class DrowsingTyrannodon < Creature
      # "As long as you control a creature with power 4 or greater, this creature can attack as
      # though it didn't have defender."
      def can_attack?
        super || (controller || owner).creatures.any? { |creature| creature.power >= 4 }
      end
    end
  end
end
