# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "[Then] discard a card unless you attacked this turn." (Chart a Course): a discard that is skipped when a
      # `Condition` holds. The discard itself is queued like any other (a `Choice::Discard`, answered with
      # `game.resolve_choice!(card:)`), so nothing may follow it that depends on the card being gone.
      class DiscardUnlessCondition < Data.define(:amount, :condition)
        include Effect

        LINE = /\A(?:Then )?discard (?<amount>an?|\d+|\w+) cards? unless (?<condition>[^.]+?)\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text)) && (condition = Condition.parse(m[:condition]))

          new(amount: Number.parse(m[:amount]), condition: condition)
        end

        def resolve_call
          discard = "game.add_choice(Magic::Choice::Discard.new(player: controller))"
          "unless #{condition}\n  #{amount == 1 ? discard : "#{amount}.times { #{discard} }"}\nend"
        end
      end
    end
  end
end
