module Magic
  class Choice
    class May < Magic::Choice
      def may?
        true
      end

      def decline!
      end
    end
  end
end
