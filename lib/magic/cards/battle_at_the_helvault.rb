module Magic
  module Cards
    BattleAtTheHelvault = Saga("Battle at the Helvault") do
      cost generic: 4, white: 2
    end

    class BattleAtTheHelvault < Saga
      AvacynToken = Token.create("Avacyn") do
        legendary_creature_type "Angel"
        power 8
        toughness 8
        colors :white
        keywords :flying, :vigilance, :indestructible
      end

      # "For each player, exile up to one target non-Saga, nonland permanent that player controls until this Saga leaves
      # the battlefield." One choice per player, asked of the Saga's controller.
      class ExileChoice < Magic::Choice::May
        attr_reader :victim

        def initialize(actor:, victim:)
          @victim = victim
          super(actor: actor)
        end

        def choices
          victim.permanents.nonland.reject { |permanent| permanent.card.is_a?(Saga) }
        end

        def resolve!(target: nil)
          return unless target

          # An exiled token ceases to exist, so there is nothing to return later.
          actor.exiled_cards << target.card unless target.token?
          actor.trigger_effect(:exile, target: target)
        end
      end

      class ExileChapter < Saga::ChapterAbility
        def resolve!
          # The newest choice is asked first, so add them in reverse to ask the Saga's controller about themselves first.
          [*game.opponents(controller), controller].each do |player|
            choice = ExileChoice.new(actor: actor, victim: player)
            game.add_choice(choice) if choice.choices.any?
          end
        end
      end

      class Chapter3 < Saga::ChapterAbility
        def resolve!
          actor.create_token(token_class: AvacynToken)
        end
      end

      # "...until this Saga leaves the battlefield": the exiled permanents return under their owners' control.
      class LeavesTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          actor.exiled_cards.each { |card| card.return_to_battlefield! if card.zone&.exile? }
        end
      end

      def ltb_triggers = [LeavesTrigger]

      def chapters
        [ExileChapter, ExileChapter, Chapter3]
      end
    end
  end
end
