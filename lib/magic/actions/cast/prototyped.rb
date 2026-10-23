module Magic
  module Actions
    class Cast
      # Rule 718 (prototype): pays the card's prototype cost instead of its mana cost. The spell, and the permanent it
      # becomes, has the prototype's mana cost, colour and power/toughness for as long as it stays on the stack or
      # battlefield (`Card#prototyped`).
      class Prototyped < Cast
        def prototyped? = true

        private

        def base_cost = card.prototype_cost

        def plain_cost? = false

        def prepare_card
          card.prototyped = true
        end

        def cost_mode_illegal_reason
          "#{card.name} has no prototype" unless card.prototype_cost
        end
      end
    end
  end
end
