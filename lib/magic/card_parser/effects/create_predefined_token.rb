# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Create a Treasure token." / "Create two Food tokens." / "Create a Clue
      # token." Uses the engine's shared token classes (Magic::Tokens).
      class CreatePredefinedToken < Data.define(:amount, :token)
        include Effect

        TOKENS = %w[Treasure Food Clue].freeze
        LINE = /\ACreate (?<amount>\d+|\w+) (?<token>#{TOKENS.join('|')}) tokens?\.?\z/

        def self.parse(text)
          new(amount: Number.parse($~[:amount]), token: $~[:token]) if LINE.match(text)
        end

        def resolve_call
          amount_arg = amount == 1 ? "" : ", amount: #{amount}"
          "trigger_effect(:create_token, token_class: Tokens::#{token}#{amount_arg})"
        end
      end
    end
  end
end
