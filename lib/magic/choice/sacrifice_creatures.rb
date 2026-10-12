module Magic
  class Choice
    # "Each player sacrifices X creatures of their choice." One of these per player: +player+ picks +amount+ of their
    # creatures (or all of them, if they have no more than that). Resolve with `game.resolve_choice!(sacrifices: [...])`.
    # `SacrificeCreatures.each_player(actor:, amount:)` asks everyone in turn order, skipping the questions with no
    # decision to make.
    class SacrificeCreatures < Choice
      def self.each_player(actor:, amount:)
        actor.game.players.each do |player|
          creatures = player.creatures.to_a
          if creatures.size <= amount
            creatures.each(&:sacrifice!)
          elsif amount.positive?
            actor.game.add_choice(new(actor: actor, player: player, amount: amount))
          end
        end
      end

      attr_reader :player, :amount

      def initialize(actor:, player:, amount:)
        super(actor: actor)
        @player = player
        @amount = amount
      end

      def chooser = player

      def prompt = "Sacrifice #{amount} #{amount == 1 ? "creature" : "creatures"}."

      def choices = player.creatures.to_a

      def resolve!(sacrifices:)
        chosen = Array(sacrifices)
        raise ArgumentError, "choose exactly #{amount} creatures" unless chosen.size == amount && chosen.uniq.size == amount
        raise ArgumentError, "choose only creatures you control" unless (chosen - choices).empty?

        chosen.each(&:sacrifice!)
      end
    end
  end
end
