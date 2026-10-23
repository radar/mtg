module Magic
  module Cards
    TamiyoMeetsTheStoryCircle = Saga("Tamiyo Meets the Story Circle") do
      cost blue: 1, generic: 1
    end

    class TamiyoMeetsTheStoryCircle < Saga
      # I -- Until your next turn, whenever a creature attacks you or a planeswalker you control, it gets -2/-0 until end
      # of turn. The effect is the Saga's own trigger, live until its controller begins another turn.
      class Chapter1 < Saga::ChapterAbility
        def resolve! = nil
      end

      class AttackTrigger < TriggeredAbility
        def should_perform?
          return false unless actor.before_controllers_next_turn?

          target = event.target
          target == controller || (target.is_a?(Permanent) && target.planeswalker? && target.controller == controller)
        end

        def call
          pump(event.attacker, -2, 0)
        end
      end

      # II -- Discard any number of cards, then investigate twice for each card discarded this way.
      class DiscardChoice < Magic::Choice
        def choices
          Magic::Targets::Choices.new(amount: 0..controller.hand.count, choices: controller.hand.to_a)
        end

        def prompt = "Discard any number of cards"

        def resolve!(choices:)
          cards = choices.to_a
          cards.each(&:move_to_graveyard!)
          (cards.count * 2).times { create_token(token: Tokens::Clue) }
        end

        def decline! = nil
      end

      class Chapter2 < Saga::ChapterAbility
        def resolve!
          game.choices.add(DiscardChoice.new(actor: actor)) if controller.hand.any?
        end
      end

      # III -- Shuffle up to three target cards from your graveyard into your library.
      class ShuffleChoice < Magic::Choice::Targeted
        def choices = controller.graveyard.cards.to_a

        def choice_amount = 0..3

        def resolve!(targets: [])
          targets.each { _1.move_zone!(to: controller.library) }
          controller.shuffle!
        end

        def decline! = nil
      end

      class Chapter3 < Saga::ChapterAbility
        def resolve!
          game.choices.add(ShuffleChoice.new(actor: actor)) if controller.graveyard.any?
        end
      end

      def chapters = [Chapter1, Chapter2, Chapter3]

      def event_handlers = super.merge(Events::CreatureAttacked => AttackTrigger)
    end
  end
end
