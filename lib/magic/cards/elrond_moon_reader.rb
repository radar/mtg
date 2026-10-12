module Magic
  module Cards
    ElrondMoonReader = Creature("Elrond, Moon-Reader") do
      cost generic: 2, blue: 1
      legendary_creature_type "Elf Noble"
      power 3
      toughness 3
    end

    class ElrondMoonReader < Creature
      # "Whenever you activate an ability of a creature, draw a card. This ability triggers only once each turn."
      class ActivatedTrigger < TriggeredAbility
        def should_perform?
          event.player == controller && event.ability.source.respond_to?(:creature?) && event.ability.source.creature? &&
            !actor.triggered_once_this_turn?(self.class)
        end

        def trigger!
          return false unless should_perform?

          actor.trigger_once_this_turn!(self.class)
          true
        end

        def call
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      # "Return those cards to the battlefield under their owner's control at the beginning of the next end step." A
      # game-level listener that removes itself once it has fired. An exiled token ceases to exist, so it isn't returned.
      class ReturnLater
        def initialize(game:, cards:)
          @game = game
          @cards = cards
        end

        def receive_event(event)
          return unless event.is_a?(Events::BeginningOfEndStep)

          @game.unsubscribe(self)
          @cards.each do |card|
            card.resolve!(controller: card.owner) if card.zone&.exile?
          end
        end
      end

      # "{5}{U}{U}: Exile up to two other target nonland permanents you control."
      class BlinkAbility < Magic::ActivatedAbility
        costs "{5}{U}{U}"

        def target_choices
          battlefield.controlled_by(controller).reject { |permanent| permanent == source || permanent.land? }
        end

        def resolve!(targets: [])
          targets = targets.first(2)
          cards = targets.reject(&:token?).map(&:card)
          targets.each { |permanent| trigger_effect(:exile, target: permanent) }
          game.subscribe(ReturnLater.new(game:, cards:)) if cards.any?
        end
      end

      def activated_abilities = [BlinkAbility]

      def event_handlers = super.merge({ Events::AbilityActivated => ActivatedTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
