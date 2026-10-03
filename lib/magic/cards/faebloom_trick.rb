module Magic
  module Cards
    FaebloomTrick = Instant("Faebloom Trick") do
      cost generic: 2, blue: 1
    end

    class FaebloomTrick < Instant
      FaerieToken = Token.create "Faerie" do
        creature_type "Faerie"
        power 1
        toughness 1
        colors :blue
        keywords :flying
      end

      class TapChoice < Magic::Choice::Targeted
        def choices
          battlefield.not_controlled_by(controller).creatures
        end

        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:tap, target: target)
        end
      end

      def resolve!
        trigger_effect(:create_token, token_class: FaerieToken, amount: 2)
        choice = TapChoice.new(actor: self)
        game.add_choice(choice) if choice.choices.any?
      end
    end
  end
end
