module Magic
  module Cards
    EagleOfTheGreatShelf = Creature("Eagle of the Great Shelf") do
      cost generic: 4, white: 1
      creature_type("Bird Soldier")
      keywords :flying
      power 2
      toughness 5
    end

    class EagleOfTheGreatShelf < Creature
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        def call
          bonus = controller.creatures.count - 1
          trigger_effect(:modify_power_toughness, target: actor, power: bonus, toughness: bonus, until_eot: true)
        end
      end

      def event_handlers = super.merge(Events::FinalAttackersDeclared => AttacksTrigger)
    end
  end
end
