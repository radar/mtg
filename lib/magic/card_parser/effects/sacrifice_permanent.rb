# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "you may sacrifice another creature. If you do, ...": like PayMana, the "may" is the choice itself
      # (`Choice::SacrificePermanent`, `game.resolve_choice!(sacrifice: creature)`) and the "If you do"
      # effects run after it is accepted. Only added to the game when there is something to sacrifice.
      # Meant for "you may sacrifice ..." (a bare mandatory "Sacrifice another creature." reads the same
      # way, so don't use it for one).
      class SacrificePermanent < Data.define(:type, :other)
        include Effect

        LINE = /\ASacrifice (?:(?<other>another)|an?) (?<type>[a-z]+)\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text)) && m[:type].downcase != "token"

          new(type: m[:type].capitalize, other: !m[:other].nil?)
        end

        def may_choice? = true
        def choice_base = "Magic::Choice::SacrificePermanent"
        def choice_class_name = "SacrificeChoice"
        def choice_args = "type: #{type.inspect}, other: #{other}"
        def choice_guard = "#{choice_base}.new(actor: #{Effect::THIS}, #{choice_args}).candidates.any?"
      end
    end
  end
end
