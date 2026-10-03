# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "As an additional cost to cast ~, sacrifice a creature." / "..., discard a card." ->
      # `additional_costs` with Costs::Sacrifice (pay with `pay_sacrifice(permanent)` on the Cast) or
      # Costs::Discard (`pay_discard(card)`). Behold is BeholdCost's.
      class AdditionalCost < Data.define(:verb, :type)
        include Rule

        TYPES = %w[creature artifact land enchantment].freeze
        LINE = /\AAs an additional cost to cast ~, (?:(?<discard>discard a card)|sacrifice an? (?<type>#{TYPES.join('|')}))\.?\z/

        def self.parse(line)
          return unless (m = LINE.match(line))

          m[:discard] ? new(verb: :discard, type: nil) : new(verb: :sacrifice, type: m[:type])
        end

        def body_source
          # A card in hand has no controller yet; whoever casts it is its owner.
          cost = if verb == :discard
                   "Costs::Discard.new(controller || owner)"
                 else
                   "Costs::Sacrifice.new(self, (controller || owner).#{Count::YOUR_PERMANENTS.fetch(type)})"
                 end
          "# #{verb == :discard ? 'Discard a card' : "Sacrifice a #{type}"} as an additional cost to cast this card.\ndef additional_costs\n  [#{cost}]\nend\n"
        end
      end
    end
  end
end
