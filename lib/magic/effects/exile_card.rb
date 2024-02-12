module Magic
  module Effects
    class ExileCard < TargetedEffect
      def inspect
        "#<Effects::ExileCard source:#{source.name} target:#{target.name}>"
      end

      def resolve!
        target.exile!
      end
    end
  end
end
