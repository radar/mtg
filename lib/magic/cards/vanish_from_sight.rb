module Magic
  module Cards
    VanishFromSight = Instant("Vanish from Sight") do
      cost generic: 3, blue: 1
    end

    class VanishFromSight < Instant
      # "Target nonland permanent's owner puts it on their choice of the top or bottom of their library."
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
          game.unsubscribe(target)
          game.battlefield.remove(target)
          card.zone = player.library
          player.library.add(card, position == :top ? 0 : player.library.count)
          # "Surveil 1." -- the spell's controller surveils.
          game.choices.add(Magic::Choice::Surveil.new(actor: actor, amount: 1))
        end
      end

      def target_choices
        battlefield.permanents.reject { _1.land? }
      end

      def resolve!(target:)
        game.choices.add(TopOrBottom.new(actor: self, target:))
      end
    end
  end
end
