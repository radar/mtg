# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # The rules text of an instant or sorcery: effect sentences, resolved in
      # order (see EffectList).
      class SpellEffect < Data.define(:effect_list)
        include Rule

        def self.parse(line)
          effect_list = EffectList.parse(line)
          new(effect_list:) if effect_list
        end

        def self.merge(rules) = [new(effect_list: rules.map(&:effect_list).reduce(:+))]

        def kinds = %i[instant sorcery]
        def effects = effect_list.effects
        def body_source = effect_list.spell_source
      end
    end
  end
end
