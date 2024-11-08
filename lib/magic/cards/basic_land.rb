module Magic
  module Cards
    class BasicLand < Land
      def self.card_name(name)
        const_set(:NAME, name)
        const_set(:TYPE_LINE, "Basic Land -- #{name}")
      end

      def self.color(color)
        mana_ability = Class.new(Magic::ManaAbility) do
          costs "{T}"
          choices color
        end

        define_method :activated_abilities do
          [mana_ability]
        end
      end
    end
  end
end
