# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "If that creature is a Goat, it also gets +3/+0 until end of turn.": an effect
      # on an earlier target, only when that target has a type.
      class IfTargetIsType < Data.define(:type, :effect)
        include Effect

        LINE = /\AIf (?:it|that creature|that permanent) is an? (?<type>[A-Z][\w-]*), (?<effect>.+)\z/

        def self.parse(text)
          return unless (m = LINE.match(text))

          effect = Effect.parse(m[:effect].sub(/\Ait also /, "it ")) or return
          new(type: m[:type], effect:) if effect.earlier_target?
        end

        def earlier_target? = true

        def resolve_call
          "if target.type?(#{type.inspect})\n#{effect.resolve_call.lines.map { "  #{_1.chomp}\n" }.join}end"
        end
      end
    end
  end
end
