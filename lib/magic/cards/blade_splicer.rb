module Magic
  module Cards
    BladeSplicer = Creature("Blade Splicer") do
      cost generic: 2, white: 1
      creature_type "Phyrexian Human Artificer"
      power 1
      toughness 1
    end

    class BladeSplicer < Creature
      GolemToken = Token.create "Golem" do
        artifact_creature_type "Golem"
        power 3
        toughness 3
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          actor.create_token(token_class: GolemToken)
        end
      end

      # "Golems you control have first strike."
      class GolemsFirstStrike < Abilities::Static::KeywordGrant
        keyword_grants Keywords::FIRST_STRIKE
        applicable_targets { source.controller.creatures.by_type("Golem") }
      end

      def etb_triggers = [EntersTrigger]
      def static_abilities = [GolemsFirstStrike]
    end
  end
end
