module Magic
  module Cards
    AuthorityOfTheConsuls = Enchantment("Authority of the Consuls") do
      cost white: 1
    end

    class AuthorityOfTheConsuls < Enchantment
      class OpponentsCreaturesEnterTapped < StaticAbility
        def forces_creature_to_enter_tapped?(_card, player) = player != controller
      end

      def static_abilities = [OpponentsCreaturesEnterTapped]

      class OpponentCreatureEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          creature? && event.permanent.controller != controller
        end

        def call
          trigger_effect(:gain_life, target: controller, life: 1)
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => OpponentCreatureEntersTrigger }
    end
  end
end
