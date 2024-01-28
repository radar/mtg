module Magic
  class Choice
    class DestroyTarget < Choice
      attr_reader :source

      def initialize(source:)
        @source = source
      end

      def choices
        raise NotImplemented
      end

      def resolve!
        source.trigger(:destroy_target, source: source, target: target)
      end
    end
  end
end
