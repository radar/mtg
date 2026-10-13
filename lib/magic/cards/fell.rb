module Magic
  module Cards
    Fell = Sorcery("Fell") do
      cost generic: 1, black: 1
    end

    class Fell < Sorcery
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        destroy(target)
      end
    end
  end
end
