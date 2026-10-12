module Magic
  module Cards
    class BreakDownTheDoor < Instant
      card_name "Break Down the Door"
      cost generic: 2, green: 1

      # "Exile target artifact."
      class ExileArtifact < Mode
        def target_choices = battlefield.artifacts

        def resolve!(target:)
          trigger_effect(:exile, target: target)
        end
      end

      # "Exile target enchantment."
      class ExileEnchantment < Mode
        def target_choices = battlefield.enchantments

        def resolve!(target:)
          trigger_effect(:exile, target: target)
        end
      end

      # "Manifest dread."
      class ManifestDreadMode < Mode
        def resolve!
          Magic::Choice::ManifestDread.perform(actor: card)
        end
      end

      modes ExileArtifact, ExileEnchantment, ManifestDreadMode
      choose_modes 1
    end
  end
end
