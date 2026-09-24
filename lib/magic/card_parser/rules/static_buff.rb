# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # Static buffs: "[Other] creatures you control get +1/+1[ and have trample]." /
      # "Creatures you control have vigilance." / "Equipped creature gets +2/+0." /
      # "Enchanted creature gets +1/+1 and has flying." A line with both a P/T change
      # and keywords becomes two static abilities (see merge).
      class StaticBuff < Data.define(:subject, :power, :toughness, :keywords)
        include Rule

        # Subject => [class name prefix, applicable targets, card kinds]
        SUBJECTS = {
          "creatures you control" => ["CreaturesYouControl", "applicable_targets { source.controller.creatures }", PERMANENT_KINDS],
          "other creatures you control" => ["CreaturesYouControl", "applicable_targets { source.controller.creatures - [source] }",
                                            PERMANENT_KINDS],
          "equipped creature" => ["EquippedCreature", "applies_to_target", %i[equipment]],
          "enchanted creature" => ["EnchantedCreature", "applies_to_target", %i[aura]]
        }.freeze
        KEYWORDS = /[\w ,]+?/
        LINE = %r{\A(?<subject>#{SUBJECTS.keys.join('|')}) (?:gets? (?<power>[+-]\d+)/(?<toughness>[+-]\d+)(?: and (?:has|have) (?<with>#{KEYWORDS}))?|(?:has|have) (?<only>#{KEYWORDS}))\.?\z}i

        def self.parse(line)
          return unless (m = LINE.match(line))

          keywords = []
          if (phrase = m[:with] || m[:only])
            keywords = Keywords.phrase(phrase) or return
          end
          new(subject: m[:subject].downcase, power: m[:power]&.to_i, toughness: m[:toughness]&.to_i, keywords:)
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

        def kinds = SUBJECTS.fetch(subject)[2]
        def hook = :static_abilities
        def class_base_name = "#{SUBJECTS.fetch(subject)[0]}#{power ? 'Buff' : 'Keywords'}"

        def class_source(name)
          targets = SUBJECTS.fetch(subject)[1]
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
