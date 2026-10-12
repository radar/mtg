module Magic
  module Cards
    class RiddlesInTheDark < Instant
      card_name "Riddles in the Dark"
      cost generic: 2, blue: 1

      # "An opponent chooses one of the piles. Put that pile into your hand and the other into your graveyard."
      # Answer with `resolve!(pile: :face_down)` or `resolve!(pile: :face_up)`.
      class OpponentChoice < Magic::Choice
        attr_reader :face_down, :face_up, :player

        def chooser = player

        def initialize(actor:, player:, face_down:, face_up:)
          @player = player
          @face_down = face_down
          @face_up = face_up
          super(actor: actor)
        end

        def prompt = "Choose a pile to put into the caster's hand (the other goes to their graveyard)"

        def choices = %i[face_down face_up]

        def resolve!(pile:)
          raise ArgumentError, "choose :face_down or :face_up" unless choices.include?(pile)

          taken, other = pile == :face_down ? [face_down, face_up] : [face_up, face_down]
          taken.each(&:move_to_hand!)
          other.each(&:move_to_graveyard!)
        end
      end

      # "Look at the top four cards of your library and separate them into a face-down pile and a face-up pile."
      # Answer with `resolve!(face_down: [cards])`; the rest of the four make the face-up pile.
      class SeparateChoice < Magic::Choice
        attr_reader :looked_at

        def initialize(actor:)
          super
          @looked_at = controller.library.first(4)
        end

        def prompt = "Separate the cards into a face-down pile and a face-up pile"

        def choices = looked_at

        def resolve!(face_down: [])
          raise ArgumentError, "choose from the top four cards" unless face_down.all? { looked_at.include?(_1) }

          opponent = game.opponents(controller).first
          game.add_choice(OpponentChoice.new(actor: actor, player: opponent, face_down: face_down, face_up: looked_at - face_down))
        end
      end

      def resolve!
        choice = SeparateChoice.new(actor: self)
        game.add_choice(choice) if choice.looked_at.any?
      end
    end
  end
end
