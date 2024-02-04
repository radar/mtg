module Magic
  module Cards
    class Sorcery < Card
      type "Sorcery"

      def permanent?
        false
      end
    end
  end
end
