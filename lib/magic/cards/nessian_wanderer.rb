module Magic
  module Cards
    NessianWanderer = Creature("Nessian Wanderer") do
      cost generic: 1, green: 1
      creature_type "Satyr Scout"
      power 2
      toughness 3
    end

    class NessianWanderer < Creature
      class LandChoice < Magic::Choice
        attr_reader :choices

        def initialize(actor:, cards:)
          @cards = cards
          @choices = cards.select(&:land?)
          super(actor: actor)
        end

        def resolve!(target:)
          @cards.each { |card| controller.library.remove(card) }
          controller.reveal(target)
          target.move_to_hand!
          rest = @cards - [target]
          rest.shuffle.each_with_index { |card, index| controller.library.add(card, controller.library.count + index) }
        end
      end

      class ConstellationTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          enchantment? && under_your_control?
        end

        def call
          cards = controller.library.take(3)
          land_cards = cards.select(&:land?)
          if land_cards.any?
            game.add_choice(LandChoice.new(actor: actor, cards: cards))
          else
            cards.each { |card| controller.library.remove(card) }
            cards.shuffle.each_with_index { |card, index| controller.library.add(card, controller.library.count + index) }
          end
        end
      end

      def event_handlers
        { Events::EnteredTheBattlefield => ConstellationTrigger }
      end
    end
  end
end