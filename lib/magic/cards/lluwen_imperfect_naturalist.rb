module Magic
  module Cards
    LluwenImperfectNaturalist = Creature("Lluwen, Imperfect Naturalist") do
      cost "{B/G}{B/G}"
      legendary_creature_type "Elf Druid"
      power 1
      toughness 3
    end

    class LluwenImperfectNaturalist < Creature
      WormToken = Token.create("Worm") do
        creature_type "Worm"
        power 1
        toughness 1
        colors :black, :green
      end

      class ReturnChoice < Magic::Choice::May
        def initialize(actor:, milled_cards:)
          super(actor: actor)
          @cards = milled_cards
        end

        def choices
          @cards.select { |card| card.creature? || card.land? }
        end

        def resolve!(target:)
          target.move_zone!(to: controller.library)
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          milled_cards = controller.mill(4)
          choice = ReturnChoice.new(actor: actor, milled_cards: milled_cards)
          game.choices.add(choice) if choice.choices.any?
        end
      end

      class CreateWormsAbility < Magic::ActivatedAbility
        def costs
          [
            Costs::Mana.new(generic: 2, black_or_green: 3),
            Costs::SelfTap.new(source),
            Costs::Discard.new(source.controller, ->(card) { card.land? })
          ]
        end

        def resolve!
          count = controller.graveyard.lands.count
          trigger_effect(:create_token, token_class: WormToken, amount: count)
        end
      end

      def etb_triggers = [EntersTrigger]
      def activated_abilities = [CreateWormsAbility]
    end
  end
end
