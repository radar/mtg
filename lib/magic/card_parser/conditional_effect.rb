# frozen_string_literal: true

module Magic
  class CardParser
    # "If there is an Elf card in your graveyard, each opponent loses 2 life and you gain 2 life."
    # (also "Then if ..."): plain effects that run only when the condition holds when the
    # sentence resolves. The effects can't be choice points or targeted; anything else is not parsed.
    class ConditionalEffect < Data.define(:condition, :effects)
      include Effect

      LINE = /\A(?:Then )?[Ii]f there is an? (?<type>[A-Z][a-z]+) card in your graveyard, (?<rest>.+)\z/

      def self.parse(sentence)
        return unless (m = LINE.match(sentence))

        list = EffectList.parse(m[:rest]) or return
        return unless list.effects.all? { plain?(_1) }

        new(condition: "controller.graveyard.cards.any? { |card| card.type?(#{m[:type].inspect}) }", effects: list.effects)
      end

      def self.plain?(effect)
        !effect.is_a?(OptionalEffect) && !effect.is_a?(self) && effect.choice_base.nil? && effect.target_choices.nil?
      end

      def definitions = effects.filter_map(&:definitions).uniq.join("\n").then { _1.empty? ? nil : _1 }

      def resolve_call
        body = effects.map(&:resolve_call).join("\n").lines.map { "  #{_1.chomp}\n" }.join
        "if #{condition}\n#{body}end"
      end
    end
  end
end
