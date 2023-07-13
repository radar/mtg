module Magic
  module Effects
    class ReturnToOwnersHand < Effect

      def requires_choices?
        true
      end

      def resolve(target)
        target.return_to_hand(target.owner)
      end
    end
  end
end
