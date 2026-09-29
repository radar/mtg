# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Create a Treasure token." / "Create two Food tokens." / "Create a Clue
      # token." / "Target player creates two Treasure tokens." Uses the engine's shared
      # token classes (Magic::Tokens).
      class CreatePredefinedToken < Data.define(:amount, :token, :who)
        include Effect

        TOKENS = %w[Treasure Food Clue].freeze
        LINE = /\A(?:(?<who>Target player|Target opponent) creates|Create) (?<amount>\d+|\w+) (?<token>#{TOKENS.join('|')}) tokens?\.?\z/

        def initialize(amount:, token:, who: nil) = super

        def self.parse(text)
          new(amount: Number.parse($~[:amount]), token: $~[:token], who: $~[:who]&.downcase) if LINE.match(text)
        end

        def target_choices = { "target player" => "game.players", "target opponent" => "game.opponents(controller)" }[who]

        def resolve_call
          args = ["token_class: Tokens::#{token}"]
          args << "amount: #{amount}" unless amount == 1
          args << "controller: target" if who
          "trigger_effect(:create_token, #{args.join(', ')})"
        end
      end
    end
  end
end
