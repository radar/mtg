module Magic
  module Cards
    TheCreationOfAvacyn = Saga("The Creation of Avacyn") do
      cost black: 2, generic: 1
    end

    class TheCreationOfAvacyn < Saga
      EXILED_CARD = :creation_of_avacyn_card

      # I -- Search your library for a card, exile it face down, then shuffle. The saga remembers the card in its
      # `state`; the engine has no hidden-information layer, so "face down" is only that nobody reads it before II.
      class Chapter1 < Saga::ChapterAbility
        class ExileChoice < Magic::Choice::SearchLibrary
          def initialize(actor:)
            super(actor: actor, filter: ->(_card) { true }, to_zone: :exile, prompt: "Search your library for a card. Exile it face down.")
          end

          def resolve!(targets:)
            card = targets.first
            if card
              card.exile!
              actor.state[EXILED_CARD] = card
            end
            chooser.shuffle!
            targets
          end

          normalize_targets :resolve!
        end

        def resolve!
          game.add_choice(ExileChoice.new(actor: actor))
        end
      end

      # II -- Turn the exiled card face up. If it's a creature card, you lose life equal to its mana value.
      class Chapter2 < Saga::ChapterAbility
        def resolve!
          card = actor.state[EXILED_CARD]
          lose_life(controller, card.mana_value) if card&.creature?
        end
      end

      # III -- You may put the exiled card onto the battlefield if it's a creature card. If you don't put it onto the
      # battlefield, put it into its owner's hand.
      class Chapter3 < Saga::ChapterAbility
        class PutOntoBattlefield < Magic::Choice::May
          def initialize(actor:, card:)
            super(actor: actor)
            @card = card
          end

          def resolve!
            @card.resolve!
          end

          def decline!
            @card.move_to_hand!(@card.owner)
          end
        end

        def resolve!
          card = actor.state[EXILED_CARD]
          return unless card

          if card.creature?
            game.add_choice(PutOntoBattlefield.new(actor: actor, card: card))
          else
            card.move_to_hand!(card.owner)
          end
        end
      end

      def chapters = [Chapter1, Chapter2, Chapter3]
    end
  end
end
