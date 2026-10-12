module Magic
  module Cards
    RoadsGoEverEverOn = Saga("Roads Go Ever, Ever On") do
      cost generic: 1, white: 1
    end

    class RoadsGoEverEverOn < Saga
      # "Search your library for up to two basic Plains cards, exile them, then shuffle."
      class ExilePlainsChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :exile, upto: 2,
                filter: ->(card) { card.any_type?("Plains") },
                prompt: "Search your library for up to two basic Plains cards. Exile them.")
        end

        def resolve!(targets:)
          raise ArgumentError, "can search for at most #{upto} cards, got #{targets.size}" if targets.size > upto

          targets.each { |card| actor.exile_with_this!(card) }
          controller.shuffle!
        end
      end

      # "Put a card exiled with this Saga into its owner's hand."
      class ReturnExiledChoice < Magic::Choice::Targeted
        def targets? = false

        def choices = actor.exiled_cards.select { |card| card.zone&.exile? }

        def choice_amount = 1

        def resolve!(target:)
          target.move_to_hand!
        end
      end

      # "Whenever you attack this turn, target creature you control gets +1/+1 until end of turn for each Plains you
      # control." A game-level listener (the Saga is sacrificed once this chapter resolves) that removes itself at the
      # end of the turn.
      class AttackListener
        class PumpChoice < Magic::Choice::Targeted
          def choices = controller.creatures

          def choice_amount = 1

          def resolve!(target:)
            plains = controller.permanents.count { |permanent| permanent.type?("Plains") }
            trigger_effect(:modify_power_toughness, target: target, power: plains, toughness: plains, until_eot: true)
          end
        end

        def initialize(game:, saga:)
          @game = game
          @saga = saga
          @controller = saga.controller
        end

        def receive_event(event)
          case event
          when Events::FinalAttackersDeclared
            return unless event.active_player == @controller && event.attacks.any?

            choice = PumpChoice.new(actor: @saga)
            @game.add_choice(choice) if choice.choices.any?
          when Events::BeginningOfEndStep
            @game.unsubscribe(self)
          end
        end
      end

      class Chapter1 < Saga::ChapterAbility
        def resolve!
          actor.game.add_choice(ExilePlainsChoice.new(actor: actor))
          actor.controller.gain_life(2)
        end
      end

      class ReturnChapter < Saga::ChapterAbility
        def resolve!
          choice = ReturnExiledChoice.new(actor: actor)
          actor.game.add_choice(choice) if choice.choices.any?
        end
      end

      class Chapter2 < ReturnChapter; end
      class Chapter3 < ReturnChapter; end

      class Chapter4 < Saga::ChapterAbility
        def resolve!
          actor.game.subscribe(AttackListener.new(game: actor.game, saga: actor))
        end
      end

      def chapters = [Chapter1, Chapter2, Chapter3, Chapter4]
    end
  end
end
