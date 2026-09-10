module Magic
  module Cards
    class CasualtiesOfWar < Sorcery
      card_name "Casualties of War"
      cost "{2}{B}{B}{G}{G}"

      class DestroyArtifact < Mode
        def target_choices
          game.battlefield.by_any_type(T::Artifact)
        end

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      class DestroyCreature < Mode
        def target_choices
          game.battlefield.creatures
        end

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      class DestroyEnchantment < Mode
        def target_choices
          game.battlefield.by_any_type(T::Enchantment)
        end

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      class DestroyLand < Mode
        def target_choices
          game.battlefield.lands
        end

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      class DestroyPlaneswalker < Mode
        def target_choices
          game.battlefield.planeswalkers
        end

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      modes DestroyArtifact, DestroyCreature, DestroyEnchantment, DestroyLand, DestroyPlaneswalker
    end
  end
end
