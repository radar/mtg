module Magic
  class Choice
    class MoveToBattlefield < Choice
      def resolve!(choices:)
        choices.each(&:resolve!)
      end
    end
  end
end
