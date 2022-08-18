module Magic
  module Permanents
    class Planeswalker < Permanent
      attr_reader :loyalty

      def initialize(**args)
        super(**args.except(:loyalty))
        @loyalty = card.loyalty
      end

      def change_loyalty!(change)
        @loyalty += change
        destroy! if loyalty <= 0
      end
    end
  end
end
