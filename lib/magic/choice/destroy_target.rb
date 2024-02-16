module Magic
  class Choice
    class DestroyTarget < Choice
      def choices
        raise NotImplemented
      end

      def resolve!
        source.trigger(:destroy_target, source: source, target: target)
      end
    end
  end
end
