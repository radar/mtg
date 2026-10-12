module Magic
  module Cards
    GleamingBarrier = Creature("Gleaming Barrier") do
      cost generic: 2
      artifact_creature_type("Wall")
      keywords :defender
      power 0
      toughness 4
    end

    class GleamingBarrier < Creature
      class DiesTrigger < TriggeredAbility::Death
        def call
          create_token(token: Tokens::Treasure)
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
