module Magic
  class Choice
    # "Choose any number of artifact tokens and/or creature tokens you control
    # with different names. For each of them, create a token that's a copy of it."
    class CopyTokens < Choice
      def prompt = "Choose any number of artifact and/or creature tokens you control with different names. Create a copy of each."

      def choices
        battlefield.controlled_by(chooser).select { |permanent| permanent.token? && (permanent.artifact? || permanent.creature?) }
      end

      def resolve!(targets:)
        raise ArgumentError, "chosen tokens must have different names" if targets.map(&:name).uniq.size < targets.size

        targets.each do |target|
          Permanent.resolve(game: game, owner: chooser, card: target.card.class.new(game: game, owner: chooser), token: true, cast: false)
        end
      end
    end
  end
end
