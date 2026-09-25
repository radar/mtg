# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # Vorinclex, Monstrous Raider's two counter replacements. One card's variants merge into a
      # single `replacement_effects` method.
      class CounterAmountChange < Data.define(:variants)
        include Rule

        VARIANTS = {
          /\AIf you would put one or more counters on a permanent or player, put twice that many of each of those kinds of counters on that permanent or player instead\.?\z/ => "CountersYouPutDoubler",
          /\AIf an opponent would put one or more counters on a permanent or player, they put half that many of each of those kinds of counters on that permanent or player instead, rounded down\.?\z/ => "CountersOpponentPutHalver",
        }.freeze

        def self.parse(line)
          _, variant = VARIANTS.find { |pattern, _| pattern.match?(line) }
          new(variants: [variant]) if variant
        end

        def self.merge(rules)
          rules.empty? ? [] : [new(variants: rules.flat_map(&:variants).uniq)]
        end

        def kinds = PERMANENT_KINDS

        def body_source
          classes = variants.map { |variant| "ReplacementEffect::#{variant}" }.join(", ")
          "def replacement_effects = [#{classes}].flat_map(&:registrations)\n"
        end
      end
    end
  end
end
