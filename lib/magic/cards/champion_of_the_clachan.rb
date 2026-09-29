module Magic
  module Cards
    ChampionOfTheClachan = Creature("Champion of the Clachan") do
      cost generic: 3, white: 1
      creature_type("Kithkin Knight")
      power 4
      toughness 5
      keywords :flash
    end

    class ChampionOfTheClachan < Creature
      # As an additional cost to cast this spell, behold a Kithkin and exile it.
      def additional_costs
        [Costs::Behold.new(self, type: "Kithkin", exile: true)]
      end

      # Other Kithkin you control get +1/+1.
      class KithkinBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        other_creatures "Kithkin"
      end

      def static_abilities = [KithkinBuff]

      # When this creature leaves the battlefield, return the exiled card to its owner's hand.
      def ltb_triggers = [Behold::ReturnExiledCardTrigger]
    end
  end
end
