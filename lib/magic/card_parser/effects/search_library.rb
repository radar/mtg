# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Search your library for a basic land card, put it onto the battlefield
      # tapped, then shuffle." / "...for up to two basic land cards, put them onto the
      # battlefield tapped, then shuffle." / "...for a Forest card, put it onto the
      # battlefield..." / "...for a creature card, reveal it, put it into your hand, then
      # shuffle." (Also as two sentences: "...for up to X basic land cards. Reveal those cards, put them
      # into your hand, then shuffle.") The search is a player choice, so the effects after it run when that
      # choice resolves.
      #
      # The card may be any card ("for a card"), a union ("an instant or sorcery card"), and
      # may carry a mana value limit ("a creature card with mana value 6 or greater").
      # "..., reveal it, then shuffle and put that card on top" puts it on top of the library
      # (`to_zone: :top`).
      class SearchLibrary < Data.define(:card, :amount, :tapped, :to_zone, :reveal, :mana_value)
        include Effect

        FILTERS = { "basic land" => "Filter[:basic_lands]", "land" => "Filter[:lands]", "creature" => "Filter[:creatures]" }.freeze
        WORD = "basic land|land|creature|artifact|enchantment|instant|sorcery|planeswalker|(?-i:[A-Z][a-z]+)"
        COMPARISONS = { "or greater" => ">=", "or less" => "<=" }.freeze
        LINE = /\ASearch your library for (?<upto>up to )?(?<amount>\d+|\w+) (?:(?<card>(?:#{WORD})(?: or (?:#{WORD}))?) )?cards?(?: with mana value (?<mv>\d+|\w+)(?: (?<cmp>or greater|or less))?)?(?:, |\. )(?<reveal>reveal (?:it|them|those cards), )?(?:put (?:it|them|those cards) (?:onto the battlefield(?<tapped> tapped)?|into your (?<hand>hand)), then shuffle|then shuffle and put (?:that card|those cards) (?<top>on top))\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text))
          return unless m[:upto] || m[:amount].match?(/\A(?:a|an|one)\z/i)

          to_zone = m[:top] ? :top : (m[:hand] ? :hand : :battlefield)
          mana_value = "#{COMPARISONS.fetch(m[:cmp]&.downcase, '==')} #{Number.parse(m[:mv])}" if m[:mv]
          new(card: m[:card]&.downcase, amount: Number.parse(m[:amount]), tapped: !m[:tapped].nil?,
              to_zone:, reveal: !m[:reveal].nil?, mana_value:)
        end

        def initialize(card:, amount:, tapped:, to_zone: :battlefield, reveal: false, mana_value: nil) = super

        def choice_base = "Magic::Choice::SearchLibrary"
        def choice_class_name = "SearchChoice"

        def choice_args
          args = ["to_zone: #{to_zone.inspect}", "enters_tapped: #{tapped}", "upto: #{amount}", "filter: #{filter}"]
          args << "reveal: true" if reveal
          args
        end

        private

        def filter
          return FILTERS[card] if mana_value.nil? && FILTERS.key?(card)

          conditions = []
          conditions << type_check if card
          conditions << "card.mana_value #{mana_value}" if mana_value
          "->(card) { #{conditions.empty? ? 'true' : conditions.join(' && ')} }"
        end

        # "instant or sorcery" -> card.any_type?("Instant", "Sorcery")
        def type_check
          types = card.split(" or ").map { _1.split.map(&:capitalize).join(" ").inspect }
          "card.any_type?(#{types.join(', ')})"
        end
      end
    end
  end
end
