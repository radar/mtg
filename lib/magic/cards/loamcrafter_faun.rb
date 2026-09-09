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

          graveyard_cards = controller.graveyard.cards.nonland.first(targets.count)
          graveyard_cards.each(&:move_to_hand!)
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