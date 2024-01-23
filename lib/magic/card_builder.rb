module Magic
  module CardBuilder
    def Instant(name, &block)
      Card(name, Magic::Cards::Instant, &block)
    end

    def Sorcery(name, &block)
      Card(name, Magic::Cards::Sorcery, &block)
    end

    def Enchantment(name, &block)
      Card(name, Magic::Cards::Enchantment, &block)
    end

    def Aura(name, &block)
      Card(name, Magic::Cards::Aura, &block)
    end

    def Creature(name, &block)
      Card(name, Magic::Cards::Creature, &block)
    end

    def Artifact(name, &block)
      Card(name, Magic::Cards::Artifact, &block)
    end

    def Card(name, base_class = Magic::Card, &block)
      card = Class.new(base_class, &block)
      card.const_set(:NAME, name)
      card
    end
  end
end
