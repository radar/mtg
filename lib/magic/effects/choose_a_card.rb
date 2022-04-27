module Magic
  module Effects
    class ChooseACard < Effect

      def requires_choices?
        true
      end

      def single_choice?
        false
      end

      def resolve(card)
        source.protections << Card::Protection.new(
          protects_player: true,
          condition: -> (c) { c.is_a?(card) }
        )
      end
    end
  end
end
