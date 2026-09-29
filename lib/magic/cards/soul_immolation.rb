module Magic
  module Cards
    class SoulImmolation < Sorcery
      card_name "Soul Immolation"
      cost generic: 3, red: 2

      # "As an additional cost to cast this spell, blight X. X can't be greater than the greatest
      # toughness among creatures you control."
      def additional_costs = [Costs::BlightX.new(self)]

      # "Soul Immolation deals X damage to each opponent and each creature they control."
      def resolve!
        x = x_blighted.to_i
        self.x_blighted = nil
        return if x.zero?

        game.opponents(controller).each do |opponent|
          trigger_effect(:deal_damage, target: opponent, damage: x)
          opponent.creatures.each { trigger_effect(:deal_damage, target: _1, damage: x) }
        end
      end
    end
  end
end
