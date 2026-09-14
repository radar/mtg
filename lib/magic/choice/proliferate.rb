module Magic
  class Choice
    # "Choose any number of permanents and/or players, then give each
    # another counter of each kind already there." Not wrapped in a
    # separate Choice::May layer -- "any number, including none" is
    # expressed by defaulting `chosen` to no entities at all.
    class Proliferate < Magic::Choice
      def choices
        game.battlefield.select { |permanent| permanent.counters.any? } +
          game.players.select { |player| player.counters.any? }
      end

      def resolve!(chosen: [])
        chosen.each do |entity|
          entity.counters.map(&:class).uniq.each { |counter_class| entity.add_counter(counter_class) }
        end
      end
    end
  end
end
