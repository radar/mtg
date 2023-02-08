module Magic
  class Stack
    class Effects < SimpleDelegator
      def unresolved
        self.class.new(reject { _1.resolved? })
      end

      def targeted
        self.class.new(select { _1.respond_to?(:targets) && _1.targets.any? })
      end

      def <<(other)
        self.class.new(super(other))
      end
    end
  end
end
