module Magic
  module Cards
    Shroudstomper = Creature("Shroudstomper") do
      cost generic: 3, white: 2, black: 2
      creature_type("Elemental")
      keywords :deathtouch
      power 5
      toughness 5
    end

    class Shroudstomper < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.opponents(controller).each { lose_life(_1, 2) }
          gain_life(2)
          draw_card
        end
      end

      def etb_triggers = [EntersTrigger]

      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        def call
          game.opponents(controller).each { lose_life(_1, 2) }
          gain_life(2)
          draw_card
        end
      end

      def event_handlers = super.merge({ Events::FinalAttackersDeclared => AttacksTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
