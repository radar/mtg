module Magic
  module Cards
    class SiegeSmash < Instant
      card_name "Siege Smash"
      cost generic: 1, red: 1
      keywords :split_second

      # Destroy target artifact.
      class DestroyArtifact < Mode
        def target_choices = battlefield.artifacts

        def resolve!(target:)
          destroy(target)
        end
      end

      # Target creature gets +3/+2 and gains trample until end of turn.
      class Pump < Mode
        def target_choices = battlefield.creatures

        def resolve!(target:)
          pump target, 3, 2
          target.grant_keyword(Keywords::TRAMPLE, until_eot: true)
        end
      end

      modes DestroyArtifact, Pump
      choose_modes 1
    end
  end
end
