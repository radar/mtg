# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # Static buffs for your creatures: "[Other] creatures you control get
      # +1/+1[ and have trample]." / "Creatures you control have vigilance."
      # A line with both becomes two static abilities (see merge).
      class Anthem < Data.define(:other, :power, :toughness, :keywords)
        include Rule

        KEYWORDS = /[\w ,]+?/
        LINE = %r{\A(?<other>Other )?creatures you control (?:get (?<power>[+-]\d+)/(?<toughness>[+-]\d+)(?: and have (?<with>#{KEYWORDS}))?|have (?<only>#{KEYWORDS}))\.?\z}i

        def self.parse(line)
          return unless (m = LINE.match(line))

          keywords = []
          if (phrase = m[:with] || m[:only])
            keywords = Keywords.phrase(phrase) or return
          end
          new(other: !m[:other].nil?, power: m[:power]&.to_i, toughness: m[:toughness]&.to_i, keywords:)
        end

        # One static ability each for the P/T change and the keywords.
        def self.merge(rules)
          rules.flat_map do |rule|
            parts = []
            parts << rule.with(keywords: []) if rule.power
            parts << rule.with(power: nil, toughness: nil) if rule.keywords.any?
            parts
          end
        end

        def kinds = PERMANENT_KINDS
        def hook = :static_abilities
        def class_base_name = power ? "CreaturesYouControlBuff" : "CreaturesYouControlKeywords"

        def class_source(name)
          targets = "applicable_targets { source.controller.creatures#{' - [source]' if other} }"
          if power
            "class #{name} < Abilities::Static::PowerAndToughnessModification\n  modify power: #{power}, toughness: #{toughness}\n  #{targets}\nend\n"
          else
            grants = keywords.map { "Keywords::#{_1.upcase}" }.join(", ")
            "class #{name} < Abilities::Static::KeywordGrant\n  keyword_grants #{grants}\n  #{targets}\nend\n"
          end
        end
      end
    end
  end
end
