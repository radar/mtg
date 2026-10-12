module Magic
  module Effects
    class ExilePermanent < MovePermanentZone
      def initialize(target:, source:)
        @source = source
        super(from: target.zone, to: game.exile, source: source, target: target)
      end

      def inspect
        "#<Effects::Exile source:#{source.name} target:#{target.name}>"
      end

      def resolve!
        super
        # A token has no card to move: it ceases to exist once it leaves the battlefield.
        target.card.exile! unless target.token?
      end
    end
  end
end
