module Magic
  module Cards
    class ConfusticateAndBebother < Instant
      card_name "Confusticate and Bebother"
      cost generic: 2, blue: 1

      # "Counter target spell unless its controller pays {4}."
      class CounterUnlessPaid < Choice
        attr_reader :target

        def initialize(actor:, target:)
          super(actor: actor)
          @target = target
        end

        def costs
          @costs ||= [Costs::Mana.new(generic: 4)]
        end

        def pay(player, payment)
          costs.first.pay!(player: player, payment: payment)
        end

        def resolve!
          trigger_effect(:counter_spell, target: target) if costs.none?(&:paid?)
        end
      end

      class CounterUnlessPay < Mode
        def target_choices = game.stack

        def resolve!(target:)
          game.choices.add(CounterUnlessPaid.new(actor: card, target: target))
        end
      end

      # "Draw two cards, then discard a card."
      class Loot < Mode
        def resolve!
          trigger_effect(:draw_cards, number_to_draw: 2)
          game.choices.add(Magic::Choice::Discard.new(player: controller, actor: card)) if controller.hand.any?
        end
      end

      modes CounterUnlessPay, Loot
      choose_modes 1
    end
  end
end
