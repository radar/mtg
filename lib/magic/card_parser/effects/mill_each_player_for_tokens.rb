# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Each player mills X cards. For each creature card put into a graveyard this way, you create a tapped
      # 2/2 black Zombie creature token." (Dread Summons). X is the spell's X (`value_for_x`), so only a
      # spell with {X} in its cost reads it.
      class MillEachPlayerForTokens < Data.define(:amount, :type, :token)
        include Effect

        LINE = /\AEach player mills (?<amount>X|\d+|\w+) cards?\. For each (?<type>[a-z]+) card put into a graveyard this way, you create (?<token>an? .+?)\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text))

          token = CreateToken.parse("Create #{m[:token]}") or return
          amount = m[:amount] == "X" ? "value_for_x" : Number.parse(m[:amount])
          new(amount:, type: m[:type].capitalize, token:)
        end

        def definitions = token.definitions

        # The spell's `resolve!` takes `value_for_x:` (see EffectList#spell_source).
        def uses_x? = amount.is_a?(String)

        def resolve_call
          counted = token.with(amount: "milled.count { _1.type?(#{type.inspect}) }")
          "milled = game.players.flat_map { _1.mill([#{amount}, _1.library.count].min) }\n#{counted.resolve_call}"
        end
      end
    end
  end
end
