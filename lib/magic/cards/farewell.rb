module Magic
  module Cards
    # "Choose one or more — Exile all artifacts. Exile all creatures. Exile all enchantments. Exile all graveyards."
    # Nothing is targeted: each chosen mode exiles everything of its kind as it resolves.
    class Farewell < Sorcery
      card_name "Farewell"
      cost generic: 4, white: 2

      class ExileArtifacts < Mode
        def resolve!
          game.battlefield.permanents.by_any_type(T::Artifact).to_a.each { |permanent| trigger_effect(:exile, target: permanent) }
        end
      end

      class ExileCreatures < Mode
        def resolve!
          game.battlefield.creatures.to_a.each { |permanent| trigger_effect(:exile, target: permanent) }
        end
      end

      class ExileEnchantments < Mode
        def resolve!
          game.battlefield.permanents.enchantments.to_a.each { |permanent| trigger_effect(:exile, target: permanent) }
        end
      end

      class ExileGraveyards < Mode
        def resolve!
          game.graveyard_cards.to_a.each { |card| trigger_effect(:exile, target: card) }
        end
      end

      choose_modes 1..4
      modes ExileArtifacts, ExileCreatures, ExileEnchantments, ExileGraveyards
    end
  end
end
