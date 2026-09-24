module Magic
  module Cards
    FightRigging = Enchantment("Fight Rigging") do
      cost generic: 2, green: 1
    end

    class FightRigging < Enchantment
      # Hideaway 5: look at the top five cards, exile one face down, put the rest on
      # the bottom of the library in a random order.
      class HideawayChoice < Magic::Choice::Targeted
        attr_reader :choices

        def initialize(actor:, cards:)
          @choices = cards
          super(actor: actor)
        end

        def choice_amount = 1

        def resolve!(target:)
          rest = choices - [target]
          target.exile!
          actor.exiled_cards << target
          rest.each { |card| library.remove(card) }
          rest.shuffle.each { |card| library.add(card, library.count) }
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          cards = controller.library.take(5)
          game.choices.add(HideawayChoice.new(actor: actor, cards: cards)) if cards.any?
        end
      end

      def etb_triggers = [EntersTrigger]

      # You may play the exiled card without paying its mana cost. It isn't the
      # main phase, so a land can't be played.
      class PlayExiledCardChoice < Magic::Choice::May
        def resolve!
          actor.exiled_cards.nonland.each do |card|
            actor.remove_from_exile(card)
            controller.cast(card: card, by_effect: true) { _1.mana_cost = 0 }
          end
        end
      end

      class CombatTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:add_counter, counter_type: "+1/+1", target: target)
            game.tick! # so the counter counts towards power
            return unless battlefield.controlled_by(controller).creatures.any? { _1.power >= 7 }
            return if actor.exiled_cards.nonland.none?

            game.choices.add(PlayExiledCardChoice.new(actor: actor))
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::BeginningOfCombat => CombatTrigger }
    end
  end
end
