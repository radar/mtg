module Magic
  module Cards
    RalAndTheImplicitMaze = Saga("Ral and the Implicit Maze") do
      cost generic: 3, red: 2
    end

    class RalAndTheImplicitMaze < Saga
      # I -- This Saga deals 2 damage to each creature and planeswalker your opponents control.
      class Chapter1 < Saga::ChapterAbility
        def resolve!
          game.battlefield.not_controlled_by(controller).select { _1.creature? || _1.planeswalker? }.each do |permanent|
            deal_damage(2, to: permanent)
          end
        end
      end

      # II -- You may discard a card. If you do, exile the top two cards of your library. You may play them until the
      # end of your next turn.
      class DiscardChoice < Magic::Choice::Discard
        def resolve!(card:)
          super
          2.times do
            top = player.library.first or break
            exile_target(top)
            game.play_permissions.grant_until_end_of_next_turn(card: top, player: player)
          end
        end
      end

      class MayDiscardChoice < Magic::Choice::May
        def resolve!
          game.choices.add(DiscardChoice.new(actor: actor, player: controller)) if hand.any?
        end
      end

      class Chapter2 < Saga::ChapterAbility
        def resolve!
          game.choices.add(MayDiscardChoice.new(actor: actor)) if controller.hand.any?
        end
      end

      # III -- Create a Spellgorger Weird token.
      class Chapter3 < Saga::ChapterAbility
        def resolve!
          create_token(token: SpellgorgerWeirdToken)
        end
      end

      SpellgorgerWeirdToken = Token.create("Spellgorger Weird") do
        creature_type "Weird"
        power 2
        toughness 2
        colors :red

        # "It's a {2}{R} 2/2 Weird creature..."
        def mana_value = 3

        def event_handlers
          { Events::SpellCast => SpellgorgerWeirdToken::SpellCastTrigger }
        end
      end

      # "Whenever you cast a noncreature spell, put a +1/+1 counter on Spellgorger Weird."
      class SpellgorgerWeirdToken
        class SpellCastTrigger < TriggeredAbility::SpellCast
          def should_perform? = you? && !spell.creature?

          def call
            add_counter("+1/+1", to: actor)
          end
        end
      end

      def chapters = [Chapter1, Chapter2, Chapter3]
    end
  end
end
