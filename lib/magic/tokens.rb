module Magic
  module Tokens
    class << self
      def Creature(name, &block)
        Card(name, Magic::Tokens::Creature, &block)
      end

      def Card(name, base_class = Magic::Token, &block)
        card = Class.new(base_class, &block)
        card.const_set(:NAME, name)
        card
      end
    end
  end
end
