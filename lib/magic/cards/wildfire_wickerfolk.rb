module Magic
  module Cards
    WildfireWickerfolk = Creature("Wildfire Wickerfolk") do
      cost red: 1, green: 1
      artifact_creature_type "Scarecrow"
      power 3
      toughness 2
      keywords :haste
    end

    class WildfireWickerfolk < Creature
      # "Delirium — This creature gets +1/+1 ... as long as there are four or more card types among cards in your
      # graveyard."
      class DeliriumBoost < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1

        conditions { source.controller.graveyard.delirium? }
        applicable_targets { [source] }
      end

      # "... and has trample as long as there are four or more card types among cards in your graveyard."
      class DeliriumTrample < Abilities::Static::KeywordGrant
        keyword_grants Keywords::TRAMPLE

        conditions { source.controller.graveyard.delirium? }
        applicable_targets { [source] }
      end

      def static_abilities = [DeliriumBoost, DeliriumTrample]
    end
  end
end
