module Magic
  module Cards
    class DestructiveTampering < Sorcery
      card_name "Destructive Tampering"
      cost generic: 2, red: 1

      # "Destroy target artifact."
      class DestroyArtifact < Mode
        def target_choices = battlefield.artifacts

        def resolve!(target:)
          trigger_effect(:destroy_target, target:)
        end
      end

      # "Creatures without flying can't block this turn." Covers the creatures on the battlefield as it resolves.
      class CantBlock < Mode
        def resolve!
          battlefield.creatures.reject(&:flying?).each(&:prevent_blocking!)
        end
      end

      modes DestroyArtifact, CantBlock
      choose_modes 1
    end
  end
end
