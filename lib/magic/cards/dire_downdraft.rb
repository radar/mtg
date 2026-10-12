module Magic
  module Cards
    class DireDowndraft < Instant
      card_name "Dire Downdraft"
      cost generic: 3, blue: 1

      def target_choices = battlefield.creatures

      # This spell costs {1} less to cast if it targets an attacking or tapped creature.
      def targets_chosen(targets)
        combat = game.current_turn.combat
        @cheaper = targets.any? { _1.tapped? || combat.attacking?(_1) }
      end

      def self_mana_cost_adjustment = { generic: -> { @cheaper ? -1 : 0 } }

      class TopOrBottom < Magic::Choice
        attr_reader :target, :player

        def initialize(actor:, target:)
          super(actor: actor)
          @target = target
          @player = target.owner
        end

        def controller = @player

        def choices = %i[top bottom]

        def resolve!(position:)
          raise ArgumentError, "choose :top or :bottom" unless choices.include?(position)

          card = target.card
          game.unsubscribe(target)
          game.battlefield.remove(target)
          card.zone = player.library
          player.library.add(card, position == :top ? 0 : player.library.count)
        end
      end

      # Target creature's owner puts it on their choice of the top or bottom of their library.
      def resolve!(target:)
        game.choices.add(TopOrBottom.new(actor: self, target: target))
      end
    end
  end
end
