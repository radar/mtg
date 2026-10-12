module Magic
  module Cards
    KardurDoomscourge = Creature("Kardur, Doomscourge") do
      cost generic: 2, black: 1, red: 1
      legendary_creature_type "Demon Berserker"
      power 4
      toughness 3
    end

    class KardurDoomscourge < Creature
      # "When Kardur enters, until your next turn, creatures your opponents control attack each combat if able and attack a
      # player other than you if able." With one opponent the second half changes nothing, so this is "attack each combat if
      # able". It is modelled as a static ability of Kardur that lasts until its controller begins another turn, so it ends
      # early if Kardur leaves the battlefield.
      class OpponentsMustAttack < Abilities::Static::MustAttack
        def applies_to?(permanent)
          permanent.creature? && @source.controller != permanent.controller && @source.before_controllers_next_turn?
        end
      end

      # "Whenever an attacking creature dies, each opponent loses 1 life and you gain 1 life."
      class AttackingCreatureDiedTrigger < TriggeredAbility
        def should_perform?
          game.current_turn.combat&.attacking?(event.permanent)
        end

        def call
          opponents.each { actor.trigger_effect(:lose_life, target: _1, life: 1) }
          actor.gain_life(1)
        end
      end

      def static_abilities = [OpponentsMustAttack]
      def event_handlers = { Events::CreatureDied => AttackingCreatureDiedTrigger }
    end
  end
end
