module Magic
  module Cards
    class CommuneWithEvil < Sorcery
      card_name "Commune with Evil"
      cost generic: 2, black: 1

      class LookAtFourChoice < Magic::Choice
        attr_reader :choices

        def initialize(actor:)
          super
          @choices = controller.library.first(4)
        end

        def resolve!(target:)
          raise ArgumentError, "#{target.name} is not one of the top four cards" unless choices.include?(target)

          target.move_to_hand!
          (choices - [target]).each(&:move_to_graveyard!)
        end
      end

      # "Look at the top four cards of your library. Put one of them into your hand and the rest into your graveyard.
      # You gain 3 life."
      def resolve!
        game.add_choice(LookAtFourChoice.new(actor: self))
        gain_life(3)
      end
    end
  end
end
