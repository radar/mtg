# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Search your library for a basic land card, put it onto the battlefield
      # tapped, then shuffle." / "...for up to two basic land cards, put them onto the
      # battlefield tapped, then shuffle." / "...for a Forest card, put it onto the
      # battlefield..." The search is a player choice, so the effects after it run
      # when that choice resolves.
      class SearchLibrary < Data.define(:card, :amount, :tapped)
        include Effect

        LINE = /\ASearch your library for (?<upto>up to )?(?<amount>\d+|\w+) (?<card>basic land|[A-Z][a-z]+) cards?, put (?:it|them) onto the battlefield(?<tapped> tapped)?, then shuffle\.?\z/

        def self.parse(text)
          return unless (m = LINE.match(text))

          new(card: m[:card], amount: Number.parse(m[:amount]), tapped: !m[:tapped].nil?) if m[:upto] || m[:amount].match?(/\A(?:a|an|one)\z/)
        end

        def choice_base = "Magic::Choice::SearchLibrary"
        def choice_class_name = "SearchChoice"

        def choice_args
          filter = card == "basic land" ? "Filter[:basic_lands]" : "->(card) { card.any_type?(#{card.inspect}) }"
          ["to_zone: :battlefield", "enters_tapped: #{tapped}", "upto: #{amount}", "filter: #{filter}"]
        end
      end
    end
  end
end
