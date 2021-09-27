module Magic
  module Effects
    class CreatureEntersControllerGainsLife
      attr_reader :source, :controller, :card, :life
      def initialize(source:, controller:, card:, life:)
        @source = source
        @controller = controller
        @card = card
        @life = life
      end

      def use_stack?
        false
      end

      def requires_choices?
        false
      end

      def resolve
        return if card == source || !card.controller?(controller)

        controller.gain_life(life) if card.creature?
      end
    end
  end
end
