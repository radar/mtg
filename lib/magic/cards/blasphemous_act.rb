module Magic
  module Cards
    class BlasphemousAct < Sorcery
      card_name "Blasphemous Act"
      cost generic: 8, red: 1

      def cost
        Costs::Mana.new(generic: [8 - creatures.count, 0].max, red: 1)
      end

      def resolve!
        creatures.each { |creature| trigger_effect(:deal_damage, target: creature, damage: 13) }
      end
    end
  end
end