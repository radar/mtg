module Magic
  module Effects
    class Noop < Effect
      def resolve!
        # no-op
      end
    end
  end
end
