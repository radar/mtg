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
        card.loyalty_abilities
      end
    end
  end
end
