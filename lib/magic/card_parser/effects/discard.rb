# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Discard a card." / "Each opponent discards a card." / "Target player discards two cards."
      class Discard < Data.define(:who, :amount)
        include Effect

        LINE = /\A(?:(?<who>target player|target opponent|each opponent|you) )?discards? (?<amount>\d+|\w+) cards?\.?\z/i

        def self.parse(text)
          new(who: $~[:who]&.downcase || "you", amount: Number.parse($~[:amount])) if LINE.match(text)
        end

        def target_choices = { "target player" => "game.players", "target opponent" => "game.opponents(controller)" }[who]

        def resolve_call
          discard = lambda do |player|
            call = "game.add_choice(Magic::Choice::Discard.new(player: #{player}))"
            amount == 1 ? call : "#{amount}.times { #{call} }"
          end
          case who
          when "each opponent" then "game.opponents(controller).each { |opponent| #{discard.('opponent')} }"
          when "you" then discard.("controller")
          else discard.("target")
          end
        end
      end
    end
  end
end
