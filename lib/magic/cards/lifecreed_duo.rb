module Magic
  module Cards
    LifecreedDuo = Creature("Lifecreed Duo") do
      cost generic: 1, white: 1
      creature_type("Bat Bird")
      keywords :flying
      power 1
      toughness 2
    end

    class LifecreedDuo < Creature
      class CreatureEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature? && under_your_control?
        end

        def call
          trigger_effect(:gain_life, target: controller, life: 1)
        end
      end

      def event_handlers = super.merge({ Events::EnteredTheBattlefield => CreatureEntersTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
