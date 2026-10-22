module Magic
  module Cards
    HexgoldSlith = Creature("Hexgold Slith") do
      cost generic: 1, white: 1
      creature_type "Slith"
      power 2
      toughness 1
    end

    class HexgoldSlith < Creature
      # When this creature enters, you get {E}{E}.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          gain_energy 2
        end
      end

      class PayChoice < Magic::Choice::PayEnergy
        def resolve!
          super
          give_keyword(actor, :first_strike) if battlefield.permanents.any? { _1.equal?(actor) }
        end
      end

      # Whenever this creature attacks, you may pay {E}{E}. If you do, it gains first strike until end of turn.
      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.attack.attacker == actor
        end

        def call
          choice = PayChoice.new(actor: actor, amount: 2)
          game.add_choice(choice) if choice.can_pay?
        end
      end

      # Whenever this creature deals combat damage to a player, put a +1/+1 counter on it.
      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          event.source == actor && event.target.player?
        end

        def call
          add_counter("+1/+1", to: actor) if battlefield.permanents.any? { _1.equal?(actor) }
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers
        super.merge({ Events::AttackDeclared => AttackTrigger, Events::CombatDamageDealt => CombatDamageTrigger }) do |_, old, new|
          [*old, *new]
        end
      end
    end
  end
end
