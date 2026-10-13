# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Target player loses 2 life." / "Each opponent loses 1 life." / "You lose 1 life." /
      # "That player loses 2 life." (the controller of the creature in a "Whenever a creature
      # an opponent controls dies" trigger: `event.permanent.controller`).
      class LoseLife < Data.define(:who, :amount)
        include Effect

        LINE = /\A(?:(?<who>target player|target opponent|each opponent|that player|you) )?loses? (?<amount>\d+|\w+) life\.?\z/i

        def self.parse(text)
          new(who: ($~[:who] || "you").downcase, amount: Number.parse($~[:amount])) if LINE.match(text)
        end

        def target_choices = { "target player" => "game.players", "target opponent" => "game.opponents(controller)" }[who]

        def resolve_call
          case who
          when "each opponent" then "game.opponents(controller).each { lose_life _1, #{amount} }"
          when "that player" then "lose_life that_player, #{amount}"
          when "you" then "lose_life controller, #{amount}"
          else "lose_life target, #{amount}"
          end
        end
      end
    end
  end
end
