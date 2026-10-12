module Magic
  module Cards
    TheSwarmweaver = Creature("The Swarmweaver") do
      cost "{2}{B}{G}"
      type T::Super::Legendary, T::Artifact, T::Creature, *creature_types("Scarecrow")
      power 2
      toughness 3
    end

    class TheSwarmweaver < Creature
      InsectToken = Token.create("Insect") do
        creature_type "Insect"
        colors :black, :green
        power 1
        toughness 1
        keywords :flying
      end

      # "When The Swarmweaver enters, create two 1/1 black and green Insect creature tokens with flying."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          2.times { actor.create_token(token_class: InsectToken) }
        end
      end

      # "Delirium — As long as there are four or more card types among cards in your graveyard, Insects and Spiders
      # you control get +1/+1 ..."
      class DeliriumBoost < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1

        conditions { source.controller.graveyard.delirium? }
        applicable_targets { source.controller.creatures.select { _1.type?("Insect") || _1.type?("Spider") } }
      end

      # "... and have deathtouch."
      class DeliriumDeathtouch < Abilities::Static::KeywordGrant
        keyword_grants Keywords::DEATHTOUCH

        conditions { source.controller.graveyard.delirium? }
        applicable_targets { source.controller.creatures.select { _1.type?("Insect") || _1.type?("Spider") } }
      end

      def etb_triggers = [EntersTrigger]

      def static_abilities = [DeliriumBoost, DeliriumDeathtouch]
    end
  end
end
