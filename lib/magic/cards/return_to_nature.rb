module Magic
  module Cards
    ReturnToNature = Instant("Return to Nature") do
      cost green: 1
    end

    class ReturnToNature < Instant
      class DestroyTargetArtifact < Mode
        def target_choices
          game.battlefield.permanents.by_any_type("Artifact")
        end

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      class DestroyTargetEnchantment < Mode
        def target_choices
          game.battlefield.permanents.by_any_type("Enchantment")
        end

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      class ExileTargetCardFromGraveyard < Mode
        def target_choices
          game.graveyard_cards
        end

        def resolve!(target:)
          trigger_effect(:exile, source: source, target: target)
        end
      end

      modes DestroyTargetArtifact,
        DestroyTargetEnchantment,
        ExileTargetCardFromGraveyard
    end
  end
end
