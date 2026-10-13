module Magic
  module Cards
    ExtinguishAllHope = Sorcery("Extinguish All Hope") do
      cost generic: 4, black: 2

      def resolve!
        creatures.non("Enchantment").each do |creature|
          destroy creature
        end

        super
      end
    end
  end
end
