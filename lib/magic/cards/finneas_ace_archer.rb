module Magic
  module Cards
    FinneasAceArcher = Creature("Finneas, Ace Archer") do
      legendary_creature_type "Rabbit Archer"
      cost green: 1, white: 1
      keywords :reach, :vigilance
      power 2
      toughness 2
    end

    class FinneasAceArcher < Creature
      # Whenever Finneas attacks, put a +1/+1 counter on each other creature you control that's a token or a
      # Rabbit. Then if creatures you control have total power 10 or greater, draw a card.
      class AttacksTrigger < TriggeredAbility
        def should_perform? = event.attacks.any? { _1.attacker == actor }

        def call
          (battlefield.controlled_by(controller).creatures - [actor]).each do |creature|
            add_counter("+1/+1", target: creature) if creature.token? || creature.type?("Rabbit")
          end
          game.tick!
          total = battlefield.controlled_by(controller).creatures.sum(&:power)
          draw_card if total >= 10
        end
      end

      def event_handlers = super.merge(Events::FinalAttackersDeclared => AttacksTrigger)
    end
  end
end
