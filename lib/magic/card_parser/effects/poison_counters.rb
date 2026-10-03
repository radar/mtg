# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "That player gets two poison counters." / "Target player gets a poison counter." / "Each opponent gets a poison
      # counter." / "You get a poison counter." ("that player" is `TriggeredAbility#that_player`, e.g. the player a
      # creature dealt combat damage to.)
      class PoisonCounters < Data.define(:who, :amount)
        include Effect

        WHO = {
          "that player" => "[that_player]",
          "each opponent" => "game.opponents(controller)",
          "you" => "[controller]"
        }.freeze
        LINE = /\A(?<who>target player|that player|each opponent|you) gets? (?<amount>\d+|\w+) poison counters?\.?\z/i

        def self.parse(text)
          new(who: $~[:who].downcase, amount: Number.parse($~[:amount])) if LINE.match(text)
        end

        def target_choices = who == "target player" ? "game.players" : nil

        def resolve_call
          return "trigger_effect(:add_counter, counter_type: \"poison\", target: target, amount: #{amount})" if who == "target player"

          "#{WHO.fetch(who)}.each { trigger_effect(:add_counter, counter_type: \"poison\", target: _1, amount: #{amount}) }"
        end
      end
    end
  end
end
