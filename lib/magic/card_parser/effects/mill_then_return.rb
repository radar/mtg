# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Mill four cards, then you may return a permanent card from among them to your hand."
      # The return is a player choice (Choice::ReturnFromAmong) over the milled cards, so the
      # effects after it run when that choice resolves.
      class MillThenReturn < Data.define(:amount, :card_type)
        include Effect

        LINE = /\AMill (?<amount>\d+|\w+) cards?, then you may return an? (?<type>permanent|[a-z-]+) card from among them to your hand\.?\z/i

        def self.parse(text)
          new(amount: Number.parse($~[:amount]), card_type: $~[:type].downcase) if LINE.match(text)
        end

        def choice_base = "Magic::Choice::ReturnFromAmong"
        def choice_class_name = "ReturnChoice"

        def choice_args
          check = card_type == "permanent" ? "card.permanent?" : "card.type?(#{card_type.capitalize.inspect})"
          ["cards: controller.mill(#{amount})", "filter: ->(card) { #{check} }"]
        end
      end
    end
  end
end
