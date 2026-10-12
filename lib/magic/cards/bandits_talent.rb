module Magic
  module Cards
    class BanditsTalent < ClassEnchantment
      card_name "Bandit's Talent"
      cost generic: 1, black: 1
      level_costs 2 => "{B}", 3 => "{3}{B}"

      # When this Class enters, each opponent discards two cards unless they discard a nonland card.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          opponents.each do |opponent|
            next if opponent.hand.none?

            game.choices.add(Magic::Choice::DiscardUnless.new(actor: actor, amount: 2, exception: ->(card) { !card.land? }, player: opponent))
          end
        end
      end

      def etb_triggers = [EntersTrigger]

      # Level 2: At the beginning of each opponent's upkeep, if that player has one or fewer cards in
      # hand, they lose 2 life.
      class UpkeepTrigger < TriggeredAbility
        def should_perform? = actor.level >= 2 && event.player != controller && event.player.hand.count <= 1

        def call
          trigger_effect(:lose_life, target: event.player, life: 2)
        end
      end

      # Level 3: At the beginning of your draw step, draw an additional card for each opponent who has
      # one or fewer cards in hand.
      class DrawStepTrigger < TriggeredAbility
        def should_perform? = actor.level >= 3 && event.player == controller

        def call
          count = opponents.count { _1.hand.count <= 1 }
          draw_cards(count) if count.positive?
        end
      end

      def event_handlers
        super.merge(Events::BeginningOfUpkeep => UpkeepTrigger, Events::DrawStep => DrawStepTrigger)
      end
    end
  end
end
