module Magic
  module Cards
    BastionOfRemembrance = Enchantment("Bastion of Remembrance") do
      cost generic: 2, black: 1
    end

    class BastionOfRemembrance < Enchantment
      HumanSoldierToken = Token.create("Human Soldier") do
        creature_type "Human Soldier"
        power 1
        toughness 1
        colors :white
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          actor.trigger_effect(:create_token, token_class: HumanSoldierToken)
        end
      end

      class CreatureDiedTrigger < TriggeredAbility
        def should_perform?
          event.controller == controller
        end

        def call
          opponents.each { |opponent| actor.trigger_effect(:lose_life, target: opponent, life: 1) }
          actor.trigger_effect(:gain_life, target: controller, life: 1)
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers
        { Events::CreatureDied => CreatureDiedTrigger }
      end
    end
  end
end