module Magic
  module Cards
    DiveDown = Instant("Dive Down") do
      cost blue: 1
    end

    class DiveDown < Instant
      def target_choices
        battlefield.controlled_by(controller).creatures
      end

      def resolve!(target:)
        pump(target, 0, 3)
        give_keyword(target, :hexproof)
      end
    end
  end
end
