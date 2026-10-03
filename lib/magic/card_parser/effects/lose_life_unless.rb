# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "That player loses 5 life unless they discard a card." (Painful Quandary) / "Each opponent loses 3 life unless
      # that player sacrifices a nonland permanent of their choice or discards a card." (Perforating Artist). The
      # affected player picks a way out (`Choice::LoseLifeUnless`, one per player); nothing may depend on the outcome.
      class LoseLifeUnless < Data.define(:who, :life, :discard, :sacrifice)
        include Effect

        WHO = { "that player" => "[that_player]", "each opponent" => "game.opponents(controller)" }.freeze
        OPTION = /(?:discards? a card|sacrifices? a nonland permanent(?: of their choice)?)/
        LINE = /\A(?<who>that player|each opponent) loses (?<life>\d+|\w+) life unless (?:that player|they) (?<options>#{OPTION}(?: or #{OPTION})?)\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text))

          new(who: m[:who].downcase, life: Number.parse(m[:life]), discard: m[:options].include?("discard"),
              sacrifice: m[:options].include?("sacrifice"))
        end

        def resolve_call
          args = ["actor: #{Effect::THIS}", "player: player", "life: #{life}"]
          args << "discard: true" if discard
          args << "sacrifice: true" if sacrifice
          "#{WHO.fetch(who)}.each { |player| game.add_choice(Magic::Choice::LoseLifeUnless.new(#{args.join(', ')})) }"
        end
      end
    end
  end
end
