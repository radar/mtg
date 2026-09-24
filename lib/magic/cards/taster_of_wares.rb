module Magic
  module Cards
    TasterOfWares = Creature("Taster of Wares") do
      cost generic: 2, black: 1
      creature_type("Goblin Warlock")
      power 3
      toughness 2
    end

    class TasterOfWares < Creature
      # "When this creature enters, target opponent reveals X cards from their hand, where
      # X is the number of Goblins you control."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices = game.opponents(controller)
          def choice_amount = 1

          def resolve!(target:)
            amount = battlefield.controlled_by(controller).creatures.by_type("Goblin").count
            reveal = RevealChoice.new(actor:, player: target, amount:)
            if reveal.choices.count <= amount
              reveal.resolve!(cards: reveal.choices.to_a)
            else
              game.add_choice(reveal)
            end
          end
        end

        def call
          choice = TargetChoice.new(actor:)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # The opponent chooses which X cards of their hand to reveal.
      class RevealChoice < Magic::Choice
        attr_reader :player, :amount

        def initialize(actor:, player:, amount:)
          super(actor:)
          @player = player
          @amount = amount
        end

        def choices = player.hand.cards

        def resolve!(cards:)
          unless cards.size == [amount, choices.count].min && cards.uniq.size == cards.size && cards.all? { choices.include?(_1) }
            raise ArgumentError, "reveal exactly #{amount} cards from your hand"
          end
          return if cards.empty?

          cards.each { _1.reveal!(notify: false) }
          game.notify!(Events::CardsRevealed.new(player:, cards:))
          game.add_choice(ExileChoice.new(actor:, cards:))
        end
      end

      # "You choose one of those cards. That player exiles it."
      class ExileChoice < Magic::Choice
        attr_reader :choices

        def initialize(actor:, cards:)
          super(actor:)
          @choices = cards
        end

        def resolve!(target:)
          raise ArgumentError, "choose one of the revealed cards" unless choices.include?(target)

          choices.each(&:conceal!)
          trigger_effect(:exile, target:)
          actor.exiled_cards << target
        end
      end

      # "If an instant or sorcery card is exiled this way, you may cast it for as long as
      # you control this creature, and mana of any type can be spent to cast that spell."
      class CastExiledSpell < StaticAbility
        def permits_casting_from_exile?(card, player)
          castable?(card, player)
        end

        def any_mana_type_for?(card, player)
          card.zone&.exile? && castable?(card, player)
        end

        private

        def castable?(card, player)
          player == controller && (card.instant? || card.sorcery?) && @source.exiled_cards.include?(card)
        end
      end

      def etb_triggers = [EntersTrigger]
      def static_abilities = [CastExiledSpell]
    end
  end
end
