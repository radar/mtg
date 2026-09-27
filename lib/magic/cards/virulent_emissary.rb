module Magic
  module Cards
    VirulentEmissary = Creature("Virulent Emissary") do
      cost green: 1
      creature_type("Elf Assassin")
      keywords :deathtouch
      power 1
      toughness 1
    end

    class VirulentEmissary < Creature
      class CreatureEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature? && under_your_control?
        end

        def call
          trigger_effect(:gain_life, target: controller, life: 1)
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => CreatureEntersTrigger }
    end
  end
end
