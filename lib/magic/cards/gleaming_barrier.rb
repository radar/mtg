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
          trigger_effect(:create_token, token_class: Tokens::Treasure)
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
