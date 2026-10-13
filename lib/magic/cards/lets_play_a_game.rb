module Magic
  module Cards
    class LetsPlayAGame < Sorcery
      card_name "Let's Play a Game"
      cost generic: 3, black: 1

      # "Delirium — Choose one. If there are four or more card types among cards in your graveyard, choose one or more
      # instead."
      def modes_to_choose = (controller || owner).graveyard.delirium? ? 1..3 : 1

      # "Creatures your opponents control get -1/-1 until end of turn."
      class ShrinkCreatures < Mode
        def resolve!
          battlefield.creatures.reject { _1.controller == controller }.each do |creature|
            creature.modify_power(-1)
            creature.modify_toughness(-1)
          end
        end
      end

      # "Each opponent discards two cards."
      class DiscardTwo < Mode
        def resolve!
          game.opponents(controller).each do |opponent|
            game.add_choice(Magic::Choice::Discard.new(player: opponent, amount: 2)) if opponent.hand.any?
          end
        end
      end

      # "Each opponent loses 3 life and you gain 3 life."
      class Drain < Mode
        def resolve!
          game.opponents(controller).each { |opponent| lose_life(opponent, 3) }
          gain_life(3)
        end
      end

      modes ShrinkCreatures, DiscardTwo, Drain
    end
  end
end
