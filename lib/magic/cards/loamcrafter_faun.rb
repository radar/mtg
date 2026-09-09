module Magic
  module Cards
    LoamcrafterFaun = Creature("Loamcrafter Faun") do
      cost generic: 2, green: 1
      creature_type "Satyr Druid"
      power 2
      toughness 3
    end

    class LoamcrafterFaun < Creature
      class Choice < Magic::Choice::May
        attr_reader :choices

        def initialize(actor:)
          @choices = actor.controller.hand.lands
          super
        end

        def resolve!(targets:)
          targets.each(&:discard!)
          return if targets.empty?

          game.add_choice(ReturnChoice.new(actor: actor, amount: targets.count))
        end
      end

      class ReturnChoice < Magic::Choice::SearchGraveyard
        def initialize(actor:, amount:)
          @amount = amount
          super(actor: actor)
        end

        def choices
          controller.graveyard.cards.nonland
        end

        def choice_amount
          @amount
        end

        def resolve!(target: nil, targets: [target].compact)
          targets.first(@amount).each(&:move_to_hand!)
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.add_choice(Choice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end