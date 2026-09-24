# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Target player loses 2 life." / "Each opponent loses 1 life." / "You lose 1 life."
      class LoseLife < Data.define(:who, :amount)
        include Effect

        LINE = /\A(?:(?<who>target player|target opponent|each opponent|you) )?loses? (?<amount>\d+|\w+) life\.?\z/i

        def self.parse(text)
          new(who: ($~[:who] || "you").downcase, amount: Number.parse($~[:amount])) if LINE.match(text)
        end

        def target_choices = { "target player" => "game.players", "target opponent" => "game.opponents(controller)" }[who]

        def resolve_call
          case who
          when "each opponent" then "game.opponents(controller).each { trigger_effect(:lose_life, target: _1, life: #{amount}) }"
          when "you" then "trigger_effect(:lose_life, target: controller, life: #{amount})"
          else "trigger_effect(:lose_life, target: target, life: #{amount})"
          end
        end
      end
    end
  end
end
