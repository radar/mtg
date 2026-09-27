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

        # A single "you discard a card" is a real choice point (which card), so effects
        # after it ("If you do, ...") nest inside its own resolve! via #effect_choice,
        # the same way Blight/Scry do -- not run as unconditional statements right after
        # queuing the choice. "Each opponent"/"target player"/N > 1 cards still add each
        # Magic::Choice::Discard the old way (#resolve_call below): several independent
        # choices, or a different actor, don't fit the single choice_base/choice_class_name
        # this effect can name.
        def choice_base
          "Magic::Choice::Discard" if who == "you" && amount == 1
        end
        def choice_class_name = "DiscardChoice"
        def choice_args = "player: controller"

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
