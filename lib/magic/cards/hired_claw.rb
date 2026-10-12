module Magic
  module Cards
    HiredClaw = Creature("Hired Claw") do
      cost red: 1
      creature_type("Lizard Mercenary")
      power 1
      toughness 2
    end

    class HiredClaw < Creature
      # Whenever you attack with one or more Lizards, this creature deals 1 damage to target opponent.
      class AttackTrigger < TriggeredAbility::YouAttack
        def should_perform? = super && attackers.any? { _1.type?("Lizard") }

        def call
          opponents.each { |opponent| trigger_effect(:deal_damage, target: opponent, damage: 1) }
        end
      end

      def event_handlers = super.merge(AttackTrigger.handlers)

      # {1}{R}: Put a +1/+1 counter on this creature. Activate only if an opponent lost life this turn and only
      # once each turn.
      class GrowAbility < Magic::ActivatedAbility
        costs "{1}{R}"
        once_each_turn

        def requirements_met? = game.current_turn.opponent_lost_life?(controller)

        def resolve!
          trigger_effect(:add_counter, counter_type: "+1/+1", target: source, amount: 1)
        end
      end

      def activated_abilities = [GrowAbility]
    end
  end
end
