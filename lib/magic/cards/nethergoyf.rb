module Magic
  module Cards
    Nethergoyf = Creature("Nethergoyf") do
      cost black: 1
      creature_type "Lhurgoyf"
      power 0
      toughness 1
    end

    class Nethergoyf < Creature
      CARD_TYPES = %w[Artifact Battle Creature Enchantment Instant Kindred Land Planeswalker Sorcery].freeze

      def self.card_types_among(cards)
        cards.flat_map { |card| CARD_TYPES.select { card.type?(_1) } }.uniq
      end

      # Characteristic-defining ability: power is the number of card types among cards in its controller's graveyard,
      # and toughness is that number plus 1 (the printed 1 is the base toughness).
      class DynamicPowerAndToughness < Abilities::Static::PowerAndToughnessModification
        def applicable_targets = [source]

        def power_modification = Nethergoyf.card_types_among(source.controller.graveyard.cards).count

        alias_method :toughness_modification, :power_modification
      end

      # Escape—{2}{B}, Exile any number of other cards from your graveyard with four or more card types among them.
      def escape_cost = Costs::Mana.new(generic: 2, black: 1)
      def escape_exile_valid?(cards) = Nethergoyf.card_types_among(cards).count >= 4

      def static_abilities = [DynamicPowerAndToughness]
    end
  end
end
