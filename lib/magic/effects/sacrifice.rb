module Magic
  module Effects
    class Sacrifice < TargetedEffect
      def resolve!
        target.sacrifice!
      end

    end
  end
end
