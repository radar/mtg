# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Each opponent discards their hand." (Myojin of Night's Reach) / "Target opponent discards their hand." /
      # "You discard your hand." The whole hand goes at once, with no choice.
      class DiscardHand < Data.define(:who)
        include Effect

        LINE = /\A(?:(?<who>each opponent|each player|target opponent|target player) discards their|(?<you>you) discard your) hand\.?\z/i
        WHO = { "each opponent" => "game.opponents(controller)", "each player" => "game.players", "you" => "[controller]" }.freeze

        def self.parse(text)
          new(who: ($~[:who] || $~[:you]).downcase) if LINE.match(text)
        end

        def target_choices = { "target opponent" => "game.opponents(controller)", "target player" => "game.players" }[who]

        def resolve_call
          players = WHO[who] || "[target]"
          "#{players}.each { |player| [*player.hand.cards].each(&:discard!) }"
        end
      end
    end
  end
end
