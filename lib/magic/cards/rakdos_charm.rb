module Magic
  module Cards
    class RakdosCharm < Instant
      card_name "Rakdos Charm"
      cost black: 1, red: 1

      class ExileGraveyard < Mode
        def target_choices
          game.players
        end

        def resolve!(target:)
          target.graveyard.cards.to_a.each { |card| card.exile! }
        end
      end

      class DestroyArtifact < Mode
        def target_choices
          game.battlefield.permanents.by_any_type(T::Artifact)
        end

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      class DamageEachCreature < Mode
        def resolve!
          game.battlefield.creatures.each do |creature|
            trigger_effect(:deal_damage, target: creature.controller, damage: 1)
          end
        end
      end

      modes ExileGraveyard, DestroyArtifact, DamageEachCreature
    end
  end
end