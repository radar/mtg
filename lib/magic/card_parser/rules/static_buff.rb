# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # Static buffs: "[Other] creatures you control get +1/+1[ and have trample]." /
      # "Creatures you control have vigilance." / "Equipped creature gets +2/+0." /
      # "Enchanted creature gets +1/+1 and has flying." / "~ gets +1/+1 for each other
      # Elf you control." A line with both a P/T change and keywords becomes two
      # static abilities (see merge). "for each ..." (Count) makes the change
      # variable: `per` is the Ruby counting it.
      class StaticBuff < Data.define(:subject, :power, :toughness, :per, :keywords)
        include Rule

        # Subject => [class name prefix, applicable targets, card kinds]
        SUBJECTS = {
          "creatures you control" => ["CreaturesYouControl", "applicable_targets { source.controller.creatures }", PERMANENT_KINDS],
          "other creatures you control" => ["CreaturesYouControl", "applicable_targets { source.controller.creatures - [source] }",
                                            PERMANENT_KINDS],
          "equipped creature" => ["EquippedCreature", "applies_to_target", %i[equipment]],
          "enchanted creature" => ["EnchantedCreature", "applies_to_target", %i[aura]],
          "~" => ["Self", "applicable_targets { [source] }", %i[creature]]
        }.freeze
        KEYWORDS = /[\w ,]+?/
        LINE = %r{\A(?<subject>#{SUBJECTS.keys.join('|')}) (?:gets? (?<power>[+-]\d+)/(?<toughness>[+-]\d+)(?: for each (?<per>[^.]+?))?(?: and (?:has|have) (?<with>#{KEYWORDS}))?|(?:has|have) (?<only>#{KEYWORDS}))\.?\z}i

        def self.parse(line)
          return unless (m = LINE.match(line))

          keywords = []
          if (phrase = m[:with] || m[:only])
            keywords = Keywords.phrase(phrase) or return
          end
          if m[:per]
            per = Count.parse(m[:per]) or return
          end
          new(subject: m[:subject].downcase, power: m[:power]&.to_i, toughness: m[:toughness]&.to_i, per:, keywords:)
        end

        # One static ability each for the P/T change and the keywords.
        def self.merge(rules)
          rules.flat_map do |rule|
            parts = []
            parts << rule.with(keywords: []) if rule.power
            parts << rule.with(power: nil, toughness: nil, per: nil) if rule.keywords.any?
            parts
          end
        end

        def kinds = SUBJECTS.fetch(subject)[2]
        def hook = :static_abilities
        def class_base_name = "#{SUBJECTS.fetch(subject)[0]}#{power ? 'Buff' : 'Keywords'}"

        def class_source(name)
          targets = SUBJECTS.fetch(subject)[1]
          if per
            "class #{name} < Abilities::Static::PowerAndToughnessModification\n  #{targets}\n\n#{variable_modifications}end\n"
          elsif power
            "class #{name} < Abilities::Static::PowerAndToughnessModification\n  modify power: #{power}, toughness: #{toughness}\n  #{targets}\nend\n"
          else
            grants = keywords.map { "Keywords::#{_1.upcase}" }.join(", ")
            "class #{name} < Abilities::Static::KeywordGrant\n  keyword_grants #{grants}\n  #{targets}\nend\n"
          end
        end

        private

        # +1/+0 for each ...: recomputed whenever continuous effects are.
        def variable_modifications
          { "power" => power, "toughness" => toughness }.reject { _2.zero? }.map do |stat, amount|
            "  def #{stat}_modification = #{amount == 1 ? per : "#{amount} * #{per}"}\n"
          end.join
        end
      end
    end
  end
end
