# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "~ endures 2." / "it endures 1." / "that creature endures X." (X from "..., where X is ..."):
      # put N +1/+1 counters on the creature or create an N/N white Spirit token. A player
      # choice (Choice::Endure): `game.resolve_choice!` for the counters, `game.skip_choice!` for
      # the token. "That creature" is the creature of the trigger's event (`event.permanent`); "it" is
      # ~, except where Rules::Trigger rewrites it to "that creature" (another creature entering).
      # Effects after an endure only run when the counters were chosen, so none are supported.
      class Endure < Data.define(:amount, :subject)
        include Effect

        LINE = /\A(?<subject>~|it|that creature) endures (?<amount>\d+|\w+)\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text))

          new(amount: Number.parse(m[:amount]), subject: m[:subject].downcase)
        end

        def choice_base = "Magic::Choice::Endure"
        def choice_class_name = "EndureChoice"

        def choice_args
          args = ["amount: #{amount}"]
          args << "creature: event.permanent" if subject == "that creature"
          args
        end
      end
    end
  end
end
