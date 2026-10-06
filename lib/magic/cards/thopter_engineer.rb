module Magic
  module Cards
    ThopterEngineer = Creature("Thopter Engineer") do
      cost generic: 2, red: 1
      creature_type "Human Artificer"
      power 1
      toughness 3
    end

    class ThopterEngineer < Creature
      ThopterToken = Token.create "Thopter" do
        artifact_creature_type "Thopter"
        power 1
        toughness 1
        keywords :flying
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          actor.create_token(token_class: ThopterToken)
        end
      end

      # "Artifact creatures you control have haste."
      class ArtifactCreaturesHaste < Abilities::Static::KeywordGrant
        keyword_grants Keywords::HASTE
        applicable_targets { source.controller.creatures.select { _1.type?("Artifact") } }
      end

      def etb_triggers = [EntersTrigger]
      def static_abilities = [ArtifactCreaturesHaste]
    end
  end
end
