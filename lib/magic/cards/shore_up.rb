module Magic
  module Cards
    ShoreUp = Instant("Shore Up") do
      cost blue: 1
    end

    class ShoreUp < Instant
      def target_choices
        battlefield.controlled_by(controller).creatures
      end

      def resolve!(target:)
        pump(target, 1, 1)
        give_keyword(target, :hexproof)
        target.untap!
      end
    end
  end
end
