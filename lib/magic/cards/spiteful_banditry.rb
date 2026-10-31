module Magic
  module Cards
    class SpitefulBanditry < Enchantment
      card_name "Spiteful Banditry"
      cost x: 1, red: 2

      # "When this enchantment enters, it deals X damage to each creature."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform? = event.permanent == actor

        def call
          x = actor.x_value.to_i
          return unless x.positive?

          battlefield.creatures.to_a.each { |creature| deal_damage(x, to: creature) }
        end
      end

      def etb_triggers = [EntersTrigger]

      # "Whenever one or more creatures your opponents control die, you create a Treasure token. This ability triggers
      # only once each turn." The guard is on queueing, so a simultaneous batch gives one trigger.
      class OpponentCreatureDiedTrigger < TriggeredAbility::OncePerTurn
        def should_perform? = opponents.include?(event.controller)

        def triggered_this_turn? = actor.triggered_once_this_turn?(self.class)

        def mark_triggered_this_turn! = actor.trigger_once_this_turn!(self.class)

        def call
          create_token(token: Tokens::Treasure, controller:)
        end
      end

      def event_handlers = super.merge({ Events::CreatureDied => OpponentCreatureDiedTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
