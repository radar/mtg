module Magic
  module Cards
    SpawnGangCommander = Creature("Spawn-Gang Commander") do
      cost generic: 3, red: 2
      creature_type "Eldrazi Goblin"
      power 2
      toughness 2
      keywords :devoid
    end

    class SpawnGangCommander < Creature
      # "When you cast this spell, create three 0/1 colorless Eldrazi Spawn creature tokens..."
      class CastTrigger < TriggeredAbility::CastThisSpell
        def call = create_eldrazi_spawn(3)
      end

      # "{1}{C}, Sacrifice an Eldrazi: This creature deals 2 damage to any target."
      class DamageAbility < Magic::ActivatedAbility
        costs "{1}{C}, Sacrifice an Eldrazi"

        def target_choices = game.any_target

        def resolve!(target:)
          deal_damage(2, to: target)
        end
      end

      def cast_triggers = [CastTrigger]
      def activated_abilities = [DamageAbility]
    end
  end
end
