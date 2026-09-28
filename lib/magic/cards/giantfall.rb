module Magic
  module Cards
    class Giantfall < Instant
      card_name "Giantfall"
      cost generic: 1, red: 1

      class FightDamage < Mode
        def multi_target? = true
        def distinct_targets? = true

        def target_choices
          [battlefield.controlled_by(controller).creatures, battlefield.not_controlled_by(controller).creatures]
        end

        def resolve!(targets:)
          attacker, victim = targets
          trigger_effect(:deal_damage, target: victim, damage: attacker.power)
        end
      end

      class DestroyArtifact < Mode
        def target_choices
          battlefield.permanents.by_any_type("Artifact")
        end

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      modes FightDamage, DestroyArtifact
    end
  end
end
