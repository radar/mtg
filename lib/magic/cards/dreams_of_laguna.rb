module Magic
  module Cards
    DreamsOfLaguna = Instant("Dreams of Laguna") do
      cost generic: 1, blue: 1
      flashback Costs::Mana.new(generic: 3, blue: 1)
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
    end
  end
end
