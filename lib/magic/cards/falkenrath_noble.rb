module Magic
  module Cards
    FalkenrathNoble = Creature("Falkenrath Noble") do
      cost generic: 3, black: 1
      creature_type "Vampire Noble"
      keywords :flying
      power 2
      toughness 2
    end

    class FalkenrathNoble < Creature
      # "Whenever this creature or another creature dies, target player loses 1 life and you gain 1 life."
      def event_handlers = { Events::CreatureDied => BloodArtist::CreatureDiedTrigger }
    end
  end
end
