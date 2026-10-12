module Magic
  module Cards
    class Stargaze < Sorcery
      card_name "Stargaze"
      cost x: 1, black: 2

      # Put X cards from among the 2X looked at into your hand and the rest into your graveyard.
      class PickChoice < Magic::Choice
        attr_reader :looked_at, :amount

        def initialize(actor:, amount:)
          super(actor: actor)
          @amount = amount
          @looked_at = controller.library.first(amount * 2)
        end

        def choices = looked_at

        def resolve!(cards:)
          picked = Array(cards)
          raise ArgumentError, "choose #{[amount, looked_at.size].min} cards" unless picked.size == [amount, looked_at.size].min && (picked - looked_at).empty?

          picked.each(&:move_to_hand!)
          (looked_at - picked).each(&:move_to_graveyard!)
          trigger_effect(:lose_life, target: controller, life: amount)
        end
      end

      # Look at twice X cards from the top of your library. Put X cards from among them into your hand and the
      # rest into your graveyard. You lose X life.
      def resolve!(value_for_x:)
        game.choices.add(PickChoice.new(actor: self, amount: value_for_x))
      end
    end
  end
end
