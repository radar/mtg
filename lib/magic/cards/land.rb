module Magic
  module Cards
    class Land < Card
      def skip_stack?
        true
      end
    end
  end
end
