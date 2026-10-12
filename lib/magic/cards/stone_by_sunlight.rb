module Magic
  module Cards
    class StoneBySunlight < Instant
      card_name "Stone by Sunlight"
      cost generic: 1, white: 1

      # Destroy target creature with power 4 or greater.
      class DestroyBig < Mode
        def target_choices = battlefield.creatures.select { _1.power >= 4 }

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      # Until end of turn, target creature becomes an artifact in addition to its other types and gains indestructible.
      class BecomeArtifact < Mode
        def target_choices = battlefield.creatures

        def resolve!(target:)
          target.add_types(T::Artifact)
          trigger_effect(:grant_keyword, target: target, keyword: :indestructible)
        end
      end

      modes DestroyBig, BecomeArtifact
      choose_modes 1
    end
  end
end
