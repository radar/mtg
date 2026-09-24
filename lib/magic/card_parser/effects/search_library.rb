# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Search your library for a basic land card, put it onto the battlefield
      # tapped, then shuffle." / "Search your library for a creature card, reveal
      # it, put it into your hand, then shuffle." A player choice
      # (Magic::Choice::SearchLibrary); effects after it run once it's made.
      class SearchLibrary < Data.define(:filter, :to_zone, :enters_tapped, :reveal)
        include Effect

        FILTERS = { "basic land" => :basic_lands, "land" => :lands, "creature" => :creatures }.freeze
        LINE = /\ASearch your library for an? (?<card>#{FILTERS.keys.join('|')}) card, (?<reveal>reveal it, )?put it (?:onto the battlefield(?<tapped> tapped)?|into your (?<hand>hand)), then shuffle\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text))

          new(filter: FILTERS.fetch(m[:card].downcase), to_zone: m[:hand] ? :hand : :battlefield, enters_tapped: !m[:tapped].nil?,
              reveal: !m[:reveal].nil?)
        end

        def choice_base = "Magic::Choice::SearchLibrary"
        def choice_class_name = "SearchChoice"

        def choice_args
          args = ["to_zone: #{to_zone.inspect}", "filter: Filter[#{filter.inspect}]"]
          args << "enters_tapped: true" if enters_tapped
          args << "reveal: true" if reveal
          args.join(", ")
        end
      end
    end
  end
end
