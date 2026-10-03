module Magic
  module Cards
    MassacreWurm = Creature("Massacre Wurm") do
      cost generic: 3, black: 3
      creature_type("Phyrexian Wurm")
      power 6
      toughness 5
    end

    class MassacreWurm < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          battlefield.not_controlled_by(controller).creatures.each { |creature| trigger_effect(:modify_power_toughness, target: creature, power: -2, toughness: -2) }
        end
      end

      def etb_triggers = [EntersTrigger]

      class CreatureDiesTrigger < TriggeredAbility
        def should_perform?
          opponent?
        end

        def call
          trigger_effect(:lose_life, target: event.permanent.controller, life: 2)
        end
      end

      def event_handlers = { Events::CreatureDied => CreatureDiesTrigger }
    end
  end
end
