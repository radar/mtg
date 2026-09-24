module Magic
  module Effects
    # A replacement effect that turns one event into several ("instead create one of each")
    # returns this. ReplacementEffectResolver runs each child effect back through the
    # remaining replacement effects on its own (rule 616.5); resolving it resolves every child.
    class Multiple < Effect
      attr_reader :effects

      def initialize(source:, effects:)
        super(source: source)
        @effects = effects
      end

      def inspect
        "#<Effects::Multiple effects:#{effects.inspect}>"
      end

      def resolve!
        effects.flat_map { |effect| Array(effect.resolve!) }
      end
    end
  end
end
