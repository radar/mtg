module Magic
  class Choice
    # "Defending player sacrifices N permanents" (annihilator): +player+ picks exactly +amount+ of their permanents.
    # `SacrificePermanents.for(actor:, player:, amount:)` sacrifices them all at once if the player has no more than
    # +amount+, and otherwise asks. Resolve with `game.resolve_choice!(sacrifices: [...])`; declining
    # (`game.skip_choice!`) sacrifices the first +amount+ permanents, since the sacrifice is mandatory.
    class SacrificePermanents < Choice
      def self.for(actor:, player:, amount:)
        permanents = player.permanents.to_a
        if permanents.size <= amount
          permanents.each(&:sacrifice!)
        elsif amount.positive?
          actor.game.add_choice(new(actor: actor, player: player, amount: amount))
        end
      end

      attr_reader :player, :amount

      def initialize(actor:, player:, amount:)
        super(actor: actor)
        @player = player
        @amount = amount
      end

      def chooser = player

      def prompt = "Sacrifice #{amount} #{amount == 1 ? "permanent" : "permanents"}."

      def choices = player.permanents.to_a

      def resolve!(sacrifices:)
        chosen = Array(sacrifices)
        raise ArgumentError, "choose exactly #{amount} permanents" unless chosen.size == amount && chosen.uniq.size == amount
        raise ArgumentError, "choose only permanents you control" unless (chosen - choices).empty?

        chosen.each(&:sacrifice!)
      end

      def decline!
        choices.first(amount).each(&:sacrifice!)
      end
    end
  end
end
