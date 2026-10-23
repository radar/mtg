module Magic
  module Cards
    class CollectiveResistance < Instant
      card_name "Collective Resistance"
      cost generic: 1, green: 1

      # Escalate {G}: pay it for each mode chosen beyond the first. `Actions::Cast#choose_mode` raises the cost, so
      # choose the modes before paying.
      def escalate_cost = { green: 1 }

      def modes_to_choose = 1..3

      # Destroy target artifact.
      class DestroyArtifact < Mode
        def target_choices = game.battlefield.artifacts

        def resolve!(target:)
          destroy(target)
        end
      end

      # Destroy target enchantment.
      class DestroyEnchantment < Mode
        def target_choices = game.battlefield.enchantments

        def resolve!(target:)
          destroy(target)
        end
      end

      # Target creature gains hexproof and indestructible until end of turn.
      class ProtectCreature < Mode
        def target_choices = game.battlefield.creatures

        def resolve!(target:)
          give_keyword(target, :hexproof)
          give_keyword(target, :indestructible)
        end
      end

      modes DestroyArtifact, DestroyEnchantment, ProtectCreature
    end
  end
end
