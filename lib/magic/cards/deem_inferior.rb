module Magic
  module Cards
    class DeemInferior < Sorcery
      card_name "Deem Inferior"
      cost generic: 3, blue: 1

      # "This spell costs {1} less to cast for each card you've drawn this turn."
      def self_mana_cost_adjustment
        player = controller || owner
        { generic: -> { -game.current_turn.events.count { _1.is_a?(Events::CardDraw) && _1.player == player } } }
      end

      def target_choices = battlefield.nonland

      # The owner picks second from the top or the bottom.
      class LibraryPositionChoice < Magic::Choice
        attr_reader :target

        def initialize(actor:, target:)
          super(actor:)
          @target = target
        end

        def chooser = target.owner

        def choices = %i[second bottom]

        def resolve!(position:)
          raise ArgumentError, "choose :second or :bottom" unless choices.include?(position)

          library = target.owner.library
          # Leaving the battlefield for real, so leaves-the-battlefield triggers see it go.
          target.move_zone!(to: library)
          return if target.copy? || target.token?

          move_card(target.card, to: library, placement: position == :second ? [1, library.count].min : library.count)
        end
      end

      # "The owner of target nonland permanent puts it into their library second from the top or on the bottom."
      def resolve!(target:)
        game.choices.add(LibraryPositionChoice.new(actor: self, target:))
      end
    end
  end
end
