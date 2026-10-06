module Magic
  module Cards
    ThoughtweftImbuer = Creature("Thoughtweft Imbuer") do
      cost generic: 3, white: 1
      creature_type("Kithkin Advisor")
      power 0
      toughness 5
    end

    class ThoughtweftImbuer < Creature
      # Whenever a creature you control attacks alone, it gets +X/+X until end of turn, where X
      # is the number of Kithkin you control.
      class AttacksAloneTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && event.attacks.one? && event.attacks.first.attacker.controller == controller
        end

        def call
          attacker = event.attacks.first.attacker
          x = controller.permanents.count { _1.type?("Kithkin") }
          trigger_effect(:modify_power_toughness, target: attacker, power: x, toughness: x, until_eot: true)
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => AttacksAloneTrigger }
    end
  end
end
