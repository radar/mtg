module Magic
  module Cards
    CruelTruths = Instant("Cruel Truths") do
      cost generic: 3, black: 1
    end

    class CruelTruths < Instant
      class SurveilChoice < Magic::Choice::Surveil
        def resolve!(**args)
          super(**args)
          trigger_effect(:draw_cards, number_to_draw: 2)
          trigger_effect(:lose_life, target: controller, life: 2)
        end
      end

      def resolve!
        game.choices.add(SurveilChoice.new(actor: self, amount: 2))
      end
    end
  end
end
