module Magic
  module Cards
    NashiSearcherInTheDark = Creature("Nashi, Searcher in the Dark") do
      cost blue: 1, black: 1
      legendary_creature_type "Rat Ninja Wizard"
      keywords :menace
      power 2
      toughness 2
    end

    class NashiSearcherInTheDark < Creature
      # "You may put any number of legendary and/or enchantment cards from among them into your
      # hand. If you put no cards into your hand this way, put a +1/+1 counter on Nashi."
      class TakeFromMilled < Magic::Choice
        attr_reader :cards

        def initialize(actor:, cards:)
          @cards = cards.to_a
          @choices = @cards.select { |card| card.legendary? || card.enchantment? }
          super(actor: actor)
        end

        attr_reader :choices

        def resolve!(cards: [])
          cards = Array(cards)
          raise ArgumentError, "not a valid choice" unless cards.all? { choices.include?(_1) }

          cards.each(&:move_to_hand!)
          trigger_effect(:add_counter, counter_type: "+1/+1", target: actor, amount: 1) if cards.empty?
        end
      end

      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          event.source == actor && event.target.is_a?(Magic::Player)
        end

        def call
          milled = controller.mill(event.damage)
          game.add_choice(TakeFromMilled.new(actor: actor, cards: milled))
        end
      end

      def event_handlers = { Events::CombatDamageDealt => CombatDamageTrigger }
    end
  end
end
