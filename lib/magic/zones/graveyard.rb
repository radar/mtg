module Magic
  module Zones
    class Graveyard < Zone

      def add(card)
        if card.is_a?(Magic::Permanent)
          card.zone = nil
          return
        end

        super
      end

      def graveyard?
        true
      end
    end
  end
end
