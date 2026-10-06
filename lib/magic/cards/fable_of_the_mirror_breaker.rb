module Magic
  module Cards
    FableOfTheMirrorBreaker = Saga("Fable of the Mirror-Breaker") do
      cost generic: 2, red: 1
    end

    class FableOfTheMirrorBreaker < Saga
      class Chapter1 < Saga::ChapterAbility
        def resolve!
          actor.create_token(token_class: GoblinShamanToken)
        end
      end

      # "You may discard up to two cards. If you do, draw that many cards."
      class DiscardUpToTwo < Magic::Choice::May
        def choices = hand.cards.to_a

        # How many cards may be picked (a UI reads it).
        def upto = 2

        def resolve!(cards:)
          cards = Array(cards)
          unless cards.size <= 2 && cards.all? { choices.include?(_1) }
            raise ArgumentError, "#{cards.map(&:name).join(', ')} is not a legal discard"
          end

          cards.each(&:move_to_graveyard!)
          cards.size.times { trigger_effect(:draw_card) }
        end
      end

      class Chapter2 < Saga::ChapterAbility
        def resolve!
          actor.game.choices.add(DiscardUpToTwo.new(actor: actor))
        end
      end

      class Chapter3 < Saga::ChapterAbility
        def resolve!
          actor.transform!(card: ReflectionOfKikiJiki.new(game: actor.game, owner: actor.controller))
        end
      end

      GoblinShamanToken = Token.create("Goblin Shaman") do
        creature_type "Goblin Shaman"
        power 2
        toughness 2
        colors :red

        def event_handlers
          { Events::CreatureAttacked => GoblinShamanToken::AttacksTrigger }
        end
      end

      class GoblinShamanToken
        class AttacksTrigger < TriggeredAbility
          def should_perform?
            this?
          end

          def call
            trigger_effect(:create_token, token_class: Tokens::Treasure)
          end
        end
      end

      def chapters
        [Chapter1, Chapter2, Chapter3]
      end
    end

  end
end