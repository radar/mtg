module Magic
  module Cards
    Savor = Instant("Savor") do
      cost generic: 1, black: 1
    end

    class Savor < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        pump(target, -2, -2)
        trigger_effect(:create_token, token_class: Tokens::Food)
      end
    end
  end
end
