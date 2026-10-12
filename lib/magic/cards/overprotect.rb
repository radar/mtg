module Magic
  module Cards
    Overprotect = Instant("Overprotect") do
      cost generic: 1, green: 1
    end

    class Overprotect < Instant
      def target_choices
        battlefield.controlled_by(controller).creatures
      end

      def resolve!(target:)
        pump(target, 3, 3)
        give_keyword(target, :trample)
        give_keyword(target, :hexproof)
        give_keyword(target, :indestructible)
      end
    end
  end
end
