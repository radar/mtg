module Magic
  module Cards
    class Sorcery < Card
      TYPE_LINE = "Sorcery"

      def permanent?
        false
      end
    end
  end
end
