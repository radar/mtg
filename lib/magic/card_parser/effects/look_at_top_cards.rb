# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Look at the top four cards of your library. You may reveal an Elf, Swamp, or Forest
      # card from among them and put it into your hand. Put the rest on the bottom of your
      # library in a random order." The pick is a player choice (Choice::LookAtTopCards), so
      # the effects after it run when that choice resolves.
      class LookAtTopCards < Data.define(:amount, :types)
        include Effect

        TYPE = /[A-Z][a-z]+/
        LINE = /\A[Ll]ook at the top (?<amount>\d+|\w+) cards? of your library\. You may reveal an? (?<types>#{TYPE}(?:, #{TYPE})*,? or #{TYPE}|#{TYPE}) card from among them and put it into your hand\. Put the rest on the bottom of your library in a random order\.?\z/

        def self.parse(text)
          return unless (m = LINE.match(text))

          new(amount: Number.parse(m[:amount]), types: m[:types].split(/,? or |, /))
        end

        def choice_base = "Magic::Choice::LookAtTopCards"
        def choice_class_name = "LookChoice"

        def choice_args
          ["amount: #{amount}", "filter: ->(card) { card.any_type?(#{types.map(&:inspect).join(', ')}) }"]
        end
      end
    end
  end
end
