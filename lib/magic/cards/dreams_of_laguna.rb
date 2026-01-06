module Magic
  module Cards
    DreamsOfLaguna = Instant("Dreams of Laguna") do
      cost generic: 1, blue: 1
    end

    class DreamsOfLaguna < Instant
      FLASHBACK_COST = { generic: 3, blue: 1 }

      class SurveilChoice < Magic::Choice::Surveil
        def resolve!(**args)
          super(**args)
          actor.trigger_effect(:draw_cards)
        end
      end

      def resolve!
        game.choices.add(SurveilChoice.new(actor: self, amount: 1))

        super
      end

      # Flashback is castable from graveyard
      def flashback_cost
        FLASHBACK_COST
      end

      class FlashbackAbility < Magic::ActivatedAbility
        def costs = []

        def resolve!
          action = Magic::Actions::Cast.new(
            card: source,
            player: source.controller,
            game: source.game,
            flashback: true
          )
          action.mana_cost = source.flashback_cost
          source.game.stack.add(action)
        end
      end

      def activated_abilities
        if zone.graveyard?
          [FlashbackAbility]
        else
          []
        end
      end
    end
  end
end
