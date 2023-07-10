module Magic
  module Effects
    class Scry < Effect
      attr_reader :player, :amount

      def initialize(source:, amount:, then_do:)
        @source = source
        @amount = amount
        super(source: source, then_do: then_do)

      end

      def requires_choices?
        true
      end

      def resolve(top: [], bottom: [])
        source.controller.scry(amount:, top:, bottom:)

        super

      end
    end
  end
end
