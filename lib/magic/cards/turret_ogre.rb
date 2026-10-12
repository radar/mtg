module Magic
  module Cards
    TurretOgre = Creature("Turret Ogre") do
      cost generic: 3, red: 1
      creature_type "Ogre Warrior"
      keywords :reach
      power 4
      toughness 3
    end

    class TurretOgre < Creature
      # "When this creature enters, if you control another creature with power 4 or greater, this
      # creature deals 2 damage to each opponent."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          (controller.creatures - [actor]).any? { |creature| creature.power >= 4 }
        end

        def call
          game.opponents(controller).each do |opponent|
            trigger_effect(:deal_damage, target: opponent, damage: 2)
          end
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
