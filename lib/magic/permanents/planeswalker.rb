module Magic
  module Permanents
    module Planeswalker
      attr_reader :loyalty

      def loyalty
        @loyalty ||= card.loyalty
      end

      def change_loyalty!(change)
        @loyalty = loyalty + change
        destroy! if loyalty <= 0
      end

      def take_damage(source:, damage:)
        game.notify!(
          Events::DamageDealt.new(
            source: source,
            target: self,
            damage: damage
          )
        )
        change_loyalty!(- damage)
      end

      def loyalty_abilities
        card.loyalty_abilities.map { |ability| ability.new(planeswalker: self) }
      end
    end
  end
end
