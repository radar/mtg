module Magic
  module Cards
    KeenEyedCurator = Creature("Keen-Eyed Curator") do
      cost green: 2
      creature_type("Raccoon Scout")
      power 3
      toughness 3
    end

    class KeenEyedCurator < Creature
      CARD_TYPES = %w[Artifact Creature Enchantment Instant Land Planeswalker Sorcery Battle].freeze

      # As long as there are four or more card types among cards exiled with this creature, it gets +4/+4 and has
      # trample.
      class ExiledTypesBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 4, toughness: 4

        def applicable_targets
          types = source.exiled_cards.flat_map { |card| KeenEyedCurator::CARD_TYPES.select { card.type?(_1) } }.uniq
          types.size >= 4 ? [source] : []
        end
      end

      class ExiledTypesTrample < Abilities::Static::KeywordGrant
        keyword_grants Keywords::TRAMPLE

        def applicable_targets
          types = source.exiled_cards.flat_map { |card| KeenEyedCurator::CARD_TYPES.select { card.type?(_1) } }.uniq
          types.size >= 4 ? [source] : []
        end
      end

      def static_abilities = [ExiledTypesBuff, ExiledTypesTrample]

      # {1}: Exile target card from a graveyard.
      class ExileAbility < Magic::ActivatedAbility
        costs "{1}"

        def target_choices = game.players.flat_map { _1.graveyard.cards.to_a }

        def resolve!(target:)
          trigger_effect(:exile, target: target)
          source.exiled_cards << target
        end
      end

      def activated_abilities = [ExileAbility]
    end
  end
end
