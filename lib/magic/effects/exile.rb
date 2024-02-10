module Magic
  module Effects
    class Exile < TargetedEffect
      def resolve!
        target.exile!
      end

      def inspect
        "#<Effects::Exile source:#{source.name} target:#{target.name}>"
      end
    end
  end
end
