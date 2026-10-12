module Magic
  module Cards
    class PerfectIntimidation < Sorcery
      card_name "Perfect Intimidation"
      cost generic: 3, black: 1

      # "Exiles two cards from their hand": the player chooses which; with fewer than that, the
      # whole hand goes.
      class ExileFromHand < Magic::Choice
        attr_reader :player, :amount

        def chooser = player

        def initialize(actor:, player:, amount:)
          @player = player
          @amount = amount
          super(actor: actor)
        end

        def choices = player.hand.cards.to_a

        def resolve!(cards:)
          cards = Array(cards)
          raise ArgumentError, "exile #{[amount, choices.size].min} cards from your hand" unless cards.size == [amount, choices.size].min && cards.all? { choices.include?(_1) }

          cards.each(&:exile!)
        end
      end

      # Target opponent exiles two cards from their hand.
      class ExileTwo < Mode
        def target_choices = game.opponents(controller)

        def resolve!(target:)
          choice = ExileFromHand.new(actor: card, player: target, amount: 2)
          game.choices.add(choice) if choice.choices.any?
        end
      end

      # Remove all counters from target creature.
      class RemoveCounters < Mode
        def target_choices = battlefield.creatures

        def resolve!(target:)
          target.counters.map(&:class).uniq.each do |counter_class|
            target.remove_counter(counter_type: counter_class, amount: target.counters.of_type(counter_class).count)
          end
        end
      end

      modes ExileTwo, RemoveCounters
      choose_modes 1..2
    end
  end
end
