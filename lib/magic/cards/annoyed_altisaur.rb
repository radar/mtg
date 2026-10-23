module Magic
  module Cards
    AnnoyedAltisaur = Creature("Annoyed Altisaur") do
      cost generic: 5, green: 2
      creature_type "Dinosaur"
      power 6
      toughness 5
      keywords :reach, :trample
    end

    class AnnoyedAltisaur < Creature
      def cast_triggers = [TriggeredAbility::Cascade]
    end
  end
end
