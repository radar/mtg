module Magic
  class Choice
    # Rule 603.3b: a player controlling two or more simultaneously triggered abilities
    # chooses the order to put them on the stack in. Only reached for 2+ triggers --
    # Stack#add_choice auto-resolves a single choice, so a lone trigger skips the
    # choice entirely (see Game#put_pending_triggers_on_stack!).
    class OrderTriggers < Targeted
      attr_reader :triggers

      def initialize(player:, triggers:)
        @player = player
        @triggers = triggers
        super(actor: player)
      end

      def controller = @player
      def choices = triggers
      def choice_amount = 1

      def resolve!(target:)
        game.pending_triggers.delete(target)
        game.stack.add(target)

        remaining = triggers - [target]
        game.add_choice(OrderTriggers.new(player: @player, triggers: remaining)) if remaining.any?
      end
    end
  end
end
