# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # Static buffs: "[Other] creatures you control get +1/+1[ and have trample]." /
      # "Creatures you control have vigilance." / "Equipped creature gets +2/+0." /
      # "Enchanted creature gets +1/+1 and has flying." / "~ gets +1/+1 for each other
      # Elf you control." A line with both a P/T change and keywords becomes two
      # static abilities (see merge). "for each ..." (Count) makes the change
      # variable: `per` is the Ruby counting it. "as long as ..." (Condition) only
      # applies it while `condition` holds. "Equipped creature gets +1/+1 and is all
      # creature types." makes the Equipment or Aura grant every creature type.
      class StaticBuff < Data.define(:subject, :power, :toughness, :per, :keywords, :condition, :all_types)
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
        LINE = %r{\A(?<subject>#{SUBJECTS.keys.join('|')}) (?:gets? (?<power>[+-]\d+)/(?<toughness>[+-]\d+)(?: for each (?<per>[^.]+?))?(?: and (?:has|have) (?<with>#{KEYWORDS}))?(?<all_types> and is all creature types)?|(?:has|have) (?<only>#{KEYWORDS}))(?: as long as (?<condition>[^.]+?))?\.?\z}i

        def self.parse(line)
          return unless (m = LINE.match(line))
          return if m[:all_types] && !%w[equipped enchanted].include?(m[:subject].downcase.split.first)

          keywords = []
          if (phrase = m[:with] || m[:only])
            keywords = Keywords.phrase(phrase) or return
          end
          if m[:per]
            per = Count.parse(m[:per]) or return
          end
          if m[:condition]
            condition = Condition.parse(m[:condition]) or return
          end
          new(subject: m[:subject].downcase, power: m[:power]&.to_i, toughness: m[:toughness]&.to_i, per:, keywords:, condition:,
              all_types: !m[:all_types].nil?)
        end

        def initialize(subject:, power:, toughness:, per:, keywords:, condition: nil, all_types: false) = super

        # One static ability each for the P/T change and the keywords.
        def self.merge(rules)
          rules.flat_map do |rule|
            parts = []
            parts << rule.with(keywords: [], all_types: false) if rule.power
            parts << rule.with(power: nil, toughness: nil, per: nil, all_types: false) if rule.keywords.any?
            parts << rule.with(power: nil, toughness: nil, per: nil, keywords: []) if rule.all_types
            parts
          end
        end

        def kinds = SUBJECTS.fetch(subject)[2]
        # "is all creature types" is a method on the Attachment, not a static ability.
        def hook = all_types ? nil : :static_abilities
        def body_source = all_types ? "def grants_all_creature_types? = true" : nil
        def class_base_name = "#{SUBJECTS.fetch(subject)[0]}#{power ? 'Buff' : 'Keywords'}"

        def class_source(name)
          targets = SUBJECTS.fetch(subject)[1]
          targets += "\n  conditions { #{condition} }" if condition
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
