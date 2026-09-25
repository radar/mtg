# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Search your library for a basic land card, put it onto the battlefield
      # tapped, then shuffle." / "...for up to two basic land cards, put them onto the
      # battlefield tapped, then shuffle." / "...for a Forest card, put it onto the
      # battlefield..." / "...for a creature card, reveal it, put it into your hand, then
      # shuffle." The search is a player choice, so the effects after it run when that
      # choice resolves.
      class SearchLibrary < Data.define(:card, :amount, :tapped, :to_zone, :reveal)
        include Effect

        FILTERS = { "basic land" => "Filter[:basic_lands]", "land" => "Filter[:lands]", "creature" => "Filter[:creatures]" }.freeze
        LINE = /\ASearch your library for (?<upto>up to )?(?<amount>\d+|\w+) (?<card>basic land|land|creature|(?-i:[A-Z][a-z]+)) cards?, (?<reveal>reveal (?:it|them), )?put (?:it|them) (?:onto the battlefield(?<tapped> tapped)?|into your (?<hand>hand)), then shuffle\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text))
          return unless m[:upto] || m[:amount].match?(/\A(?:a|an|one)\z/i)

          new(card: m[:card], amount: Number.parse(m[:amount]), tapped: !m[:tapped].nil?,
              to_zone: m[:hand] ? :hand : :battlefield, reveal: !m[:reveal].nil?)
        end

        def initialize(card:, amount:, tapped:, to_zone: :battlefield, reveal: false) = super

        def choice_base = "Magic::Choice::SearchLibrary"
        def choice_class_name = "SearchChoice"

        def choice_args
          filter = FILTERS.fetch(card.downcase) { "->(card) { card.any_type?(#{card.inspect}) }" }
          args = ["to_zone: #{to_zone.inspect}", "enters_tapped: #{tapped}", "upto: #{amount}", "filter: #{filter}"]
          args << "reveal: true" if reveal
          args
        end
      end
    end
  end
end
