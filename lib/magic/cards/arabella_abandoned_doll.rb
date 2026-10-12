module Magic
  module Cards
    ArabellaAbandonedDoll = Creature("Arabella, Abandoned Doll") do
      cost red: 1, white: 1
      type T::Super::Legendary, T::Artifact, T::Creature, *creature_types("Toy")
      power 1
      toughness 3
    end

    class ArabellaAbandonedDoll < Creature
      # "Whenever Arabella attacks, it deals X damage to each opponent and you gain X life, where X is the number of
      # creatures you control with power 2 or less."
      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        def call
          x = controller.creatures.count { _1.power <= 2 }
          return if x.zero?

          opponents.each { trigger_effect(:deal_damage, target: _1, damage: x) }
          gain_life(x)
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => AttackTrigger }
    end
  end
end
