module Magic
  module Cards
    class SeasonOfTheBold < Sorcery
      card_name "Season of the Bold"
      cost generic: 3, red: 2

      # {P} -- Create a tapped Treasure token.
      class TappedTreasure < Mode
        points 1

        def resolve!
          trigger_effect(:create_token, token_class: Tokens::Treasure, enters_tapped: true)
        end
      end

      # {P}{P} -- Exile the top two cards of your library. Until the end of your next turn, you may play them.
      class ExileTwo < Mode
        points 2

        def resolve!
          controller.library.first(2).each do |top|
            trigger_effect(:exile, target: top)
            game.play_permissions.grant_until_end_of_next_turn(card: top, player: controller)
          end
        end
      end

      # Until the end of your next turn, whenever you cast a spell, Season of the Bold deals 2 damage to up to one
      # target creature. A game-level listener that removes itself once your next turn ends.
      class CastListener
        def initialize(game:, source:, player:, from_turn:)
          @game = game
          @source = source
          @player = player
          @from_turn = from_turn
        end

        class DamageChoice < Magic::Choice::Targeted
          def choices = battlefield.creatures

          def choice_amount = 0..1

          def resolve!(target:)
            trigger_effect(:deal_damage, target: target, damage: 2)
          end
        end

        def receive_event(event)
          case event
          when Events::SpellCast
            return unless event.player == @player

            choice = DamageChoice.new(actor: @source)
            @game.add_choice(choice) if choice.choices.any?
          when Events::BeginningOfEndStep
            @game.unsubscribe(self) if event.active_player == @player && @game.current_turn.number > @from_turn
          end
        end
      end

      # {P}{P}{P} -- Until the end of your next turn, whenever you cast a spell, deal 2 damage to up to one
      # target creature.
      class DamageOnCast < Mode
        points 3

        def resolve!
          game.subscribe(CastListener.new(game: game, source: card, player: controller, from_turn: game.current_turn.number))
        end
      end

      modes TappedTreasure, ExileTwo, DamageOnCast
      modes_budget 5
    end
  end
end
