module Magic
  module Cards
    class DecreeOfJustice < Sorcery
      card_name "Decree of Justice"
      cost x: 2, generic: 2, white: 2
      cycling generic: 2, white: 1

      AngelToken = Token.create "Angel" do
        creature_type "Angel"
        power 4
        toughness 4
        colors :white
        keywords :flying
      end

      SoldierToken = Token.create "Soldier" do
        creature_type "Soldier"
        power 1
        toughness 1
        colors :white
      end

      # "Create X 4/4 white Angel creature tokens with flying."
      def resolve!(value_for_x:)
        create_token(token: AngelToken, amount: value_for_x) if value_for_x.to_i.positive?
      end

      # "When you cycle this card, you may pay {X}. If you do, create X 1/1 white Soldier creature tokens." The player
      # picks X when accepting, so `resolve_choice!(x: 2)` pays {2} and makes two Soldiers; declining pays nothing.
      class PaySoldiersChoice < Magic::Choice::May
        def initialize(actor:)
          super(actor: actor)
        end

        def resolve!(x:, payment: nil)
          return if x.zero?

          cost = Costs::Mana.new(generic: x)
          raise ArgumentError, "cannot pay {#{x}}" unless cost.can_pay?(chooser)

          if payment
            cost.pay!(player: chooser, payment: payment)
          else
            cost.auto_pay(player: chooser)
            cost.finalize!(chooser)
          end
          actor.create_token(token: SoldierToken, controller: chooser, amount: x)
        end
      end

      def cycling_effect!
        super
        game.choices.add(PaySoldiersChoice.new(actor: self))
      end
    end
  end
end
