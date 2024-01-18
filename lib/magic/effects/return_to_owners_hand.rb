module Magic
  module Effects
    class ReturnToOwnersHand < Effect

      def requires_choices?
        true
      end

      def resolve(target)
        target.return_to_hand
      end
    end
  end
end
