# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Mill two cards." / "Each opponent mills three cards." / "Target player mills two cards."
      class Mill < Data.define(:who, :amount)
        include Effect

        LINE = /\A(?:(?<who>target player|target opponent|each opponent|you) )?mills? (?<amount>\d+|\w+) cards?\.?\z/i

        def self.parse(text)
          new(who: $~[:who]&.downcase || "you", amount: Number.parse($~[:amount])) if LINE.match(text)
        end

        def target_choices = { "target player" => "game.players", "target opponent" => "game.opponents(controller)" }[who]

        def resolve_call
          case who
          when "each opponent" then "game.opponents(controller).each { |opponent| opponent.mill(#{amount}) }"
          when "you" then "controller.mill(#{amount})"
          else "target.mill(#{amount})"
          end
        end
      end
    end
  end
end
