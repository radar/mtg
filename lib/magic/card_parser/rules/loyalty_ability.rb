# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # A planeswalker's loyalty abilities: "+1: Draw a card. You lose 1 life.",
      # "−3: Destroy target creature.", "0: ...". A card's lines merge into one rule that
      # generates a LoyaltyAbility per line, in order, plus `def loyalty_abilities`. The
      # effects render like an activated ability's (EffectList#spell_source), so a target is
      # chosen when the ability is activated. "−X" abilities are not supported.
      class LoyaltyAbility < Data.define(:abilities)
        include Rule

        MINUS = "[−–-]"
        LINE = /\A(?<change>[+]\d+|#{MINUS}\d+|0): (?<effects>.+)\z/

        def self.parse(line)
          return unless (m = LINE.match(line))

          effect_list = EffectList.parse(m[:effects]) or return
          new(abilities: [[m[:change].sub(/#{MINUS}/, "-").delete("+").to_i, effect_list, m[:effects]]])
        end

        def self.merge(rules) = [new(abilities: rules.flat_map(&:abilities))]

        def kinds = %i[planeswalker]

        def body_source
          classes = abilities.each_with_index.map { |(change, effects, text), index| ability_source(index + 1, change, effects, text) }
          names = abilities.each_index.map { "LoyaltyAbility#{_1 + 1}" }
          [*classes, "def loyalty_abilities = [#{names.join(', ')}]\n"].join("\n")
        end

        private

        def ability_source(number, change, effect_list, text)
          lines = ["def loyalty_change = #{change}\n"]
          lines << "def description = #{text.inspect}\n" if text
          body = [*lines, effect_list.spell_source(this: "source")].join("\n")
          "class LoyaltyAbility#{number} < LoyaltyAbility\n#{body.gsub(/^(?=.)/, '  ')}end\n"
        end
      end
    end
  end
end
