module Magic
  module CardBuilder
    def Instant(name, &block)
      Card(name, Magic::Cards::Instant, &block)
    end
    def Creature(name, &block)
      Card(name, Magic::Cards::Creature, &block)
    end

    def Card(name, base_class = Magic::Card, &block)
      card = Class.new(base_class)
      card.const_set(:NAME, name)
      CardTemplate.new(card).instance_eval(&block)
      card
    end

    class CardTemplate
      def initialize(card)
        @card = card
      end

      def type(type)
        @card.const_set(:TYPE_LINE, type)
      end

      def cost(cost)
        @card.const_set(:COST, cost)
      end

      def power(power)
        @card.const_set(:POWER, power)
      end

      def toughness(power)
        @card.const_set(:TOUGHNESS, power)
      end

      def keywords(*keywords)
        @card.const_set(:KEYWORDS, keywords)
      end
    end
  end
end
