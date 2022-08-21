module Magic
  module Tokens
    class Creature < Cards::Creature
      def token?
        true
      end
    end
  end
end
