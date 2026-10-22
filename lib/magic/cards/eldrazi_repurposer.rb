module Magic
  module Cards
    EldraziRepurposer = Creature("Eldrazi Repurposer") do
      cost generic: 2, green: 1
      creature_type "Eldrazi Drone"
      power 3
      toughness 3
      keywords :devoid
    end

    class EldraziRepurposer < Creature
      # "When you cast this spell, create a 0/1 colorless Eldrazi Spawn creature token..."
      class CastTrigger < TriggeredAbility::CastThisSpell
        def call = create_eldrazi_spawn
      end

      # "...and when this creature dies, create a 0/1 colorless Eldrazi Spawn creature token..."
      class DiesTrigger < TriggeredAbility::Death
        def call = create_eldrazi_spawn
      end

      def cast_triggers = [CastTrigger]
      def death_triggers = [DiesTrigger]
    end
  end
end
