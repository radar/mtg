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
        target.card.exile!
      end
    end
  end
end
