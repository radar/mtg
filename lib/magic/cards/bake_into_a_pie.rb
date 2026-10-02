module Magic
  module Cards
    BakeIntoAPie = Instant("Bake into a Pie") do
      cost generic: 2, black: 2
    end

    class BakeIntoAPie < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        trigger_effect(:destroy_target, target: target)
        trigger_effect(:create_token, token_class: Tokens::Food)
      end
    end
  end
end
