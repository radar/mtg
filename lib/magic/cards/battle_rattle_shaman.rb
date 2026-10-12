module Magic
  module Cards
    BattleRattleShaman = Creature("Battle-Rattle Shaman") do
      cost generic: 3, red: 1
      creature_type "Goblin Shaman"
      power 2
      toughness 2
    end

    class BattleRattleShaman < Creature
      # "You may have target creature get +2/+0 until end of turn." Declining is `game.skip_choice!`.
      class PumpChoice < Magic::Choice::Targeted
        def choices = battlefield.creatures
        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:modify_power_toughness, target:, power: 2, toughness: 0)
        end
      end

      # "At the beginning of combat on your turn, ..."
      class BeginningOfCombatTrigger < TriggeredAbility
        def should_perform? = event.active_player == controller

        def call
          game.add_choice(PumpChoice.new(actor:))
        end
      end

      def event_handlers = { Events::BeginningOfCombat => BeginningOfCombatTrigger }
    end
  end
end
