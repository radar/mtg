# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "When ~ enters, draw a card." / "When ~ enters the battlefield, it deals
      # 1 damage to any target." Any effects EffectList can parse.
      class EntersTrigger < Data.define(:effect_list)
        include Rule

        LINE = /\AWhen ~ enters(?: the battlefield)?, (?<effects>.+)\z/

        def self.parse(line)
          return unless (m = LINE.match(line))

          effect_list = EffectList.parse(m[:effects])
          new(effect_list:) if effect_list
        end

        def kinds = %i[creature enchantment artifact equipment aura saga land]
        def hook = :etb_triggers
        def class_base_name = "EntersTrigger"

        def class_source(name)
          body = effect_list.trigger_source.gsub(/^(?=.)/, "  ").chomp
          "class #{name} < TriggeredAbility::EnterTheBattlefield\n#{body}\nend\n"
        end
      end
    end
  end
end
