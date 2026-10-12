module Magic
  module Cards
    BlossomingDefense = Instant("Blossoming Defense") do
      cost green: 1
    end

    class BlossomingDefense < Instant
      def target_choices
        battlefield.controlled_by(controller).creatures
      end

      def resolve!(target:)
        pump(target, 2, 2)
        give_keyword(target, :hexproof)
      end
    end
  end
end
