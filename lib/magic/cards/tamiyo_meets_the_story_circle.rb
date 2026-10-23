module Magic
  module Cards
    TamiyoMeetsTheStoryCircle = Saga("Tamiyo Meets the Story Circle") do
      cost blue: 1, generic: 1
    end

    class TamiyoMeetsTheStoryCircle < Saga
      # I -- Until your next turn, whenever a creature attacks you or a planeswalker you control, it gets -2/-0 until end
      # of turn. A delayed trigger, so it outlives the Saga leaving the battlefield or losing its abilities.
      class Chapter1 < Saga::ChapterAbility
        def resolve!
          game.add_delayed_trigger(source: actor, event_class: Events::CreatureAttacked, trigger_class: AttackTrigger, until_turn_of: controller)
        end

        def game = actor.game
        def controller = actor.controller
      end

      class AttackTrigger < TriggeredAbility
        def should_perform?
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
          cards.each(&:discard!)
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
    end
  end
end
