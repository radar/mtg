module Magic
  module Cards
    class SwatAway < Instant
      card_name "Swat Away"
      cost generic: 2, blue: 2

      # "This spell costs {2} less to cast if a creature is attacking you."
      def self_mana_cost_adjustment
        player = controller || owner
        { generic: -> { game.current_turn.attacks.any? { |attack| attack.target == player } ? -2 : 0 } }
      end

      def single_target?
        true
      end

      def target_choices
        [*game.stack.spells.reject { |spell| spell.card == self }, *battlefield.creatures]
      end

      # "The owner of target spell or creature puts it on their choice of the top or
      # bottom of their library."
      class TopOrBottom < Magic::Choice
        attr_reader :target, :player

        def chooser = player

        def initialize(actor:, target:)
          super(actor:)
          @target = target
          @player = target.card.owner
        end

        def choices = %i[top bottom]

        def resolve!(position:)
          raise ArgumentError, "choose :top or :bottom" unless choices.include?(position)

          card = target.card
          if target.is_a?(Magic::Permanent)
            game.unsubscribe(target)
            game.battlefield.remove(target)
          else
            game.stack.remove(target)
          end
          card.zone = player.library
          player.library.add(card, position == :top ? 0 : player.library.count)
        end
      end

      def resolve!(target:)
        game.choices.add(TopOrBottom.new(actor: self, target:))
      end
    end
  end
end
