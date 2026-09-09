module Magic
  module Cards
    class Farewell < Sorcery
      card_name "Farewell"
      cost generic: 4, white: 2

      class ExileArtifacts < Mode
        def target_choices
          game.battlefield.permanents.by_any_type(T::Artifact)
        end

        def resolve!(target:)
          trigger_effect(:exile, target: target)
        end
      end

      class ExileCreatures < Mode
        def target_choices
          game.battlefield.creatures
        end

        def resolve!(target:)
          trigger_effect(:exile, target: target)
        end
      end

      class ExileEnchantments < Mode
        def target_choices
          game.battlefield.permanents.enchantments
        end

        def resolve!(target:)
          trigger_effect(:exile, target: target)
        end
      end

      class ExileGraveyards < Mode
        def target_choices
          game.graveyard_cards
        end

        def resolve!(target:)
          trigger_effect(:exile, target: target)
        end
      end

      modes ExileArtifacts, ExileCreatures, ExileEnchantments, ExileGraveyards
    end
  end
end