module Magic
  module Cards
    PatchworkBeastie = Creature("Patchwork Beastie") do
      cost green: 1
      artifact_creature_type "Beast"
      power 3
      toughness 3
    end

    class PatchworkBeastie < Creature
      # "Delirium — This creature can't attack or block unless there are four or more card types among cards in your
      # graveyard."
      def can_attack?
        super && (controller || owner).graveyard.delirium?
      end

      def can_block?(attacker)
        super && (controller || owner).graveyard.delirium?
      end

      # "At the beginning of your upkeep, you may mill a card."
      class MillChoice < Magic::Choice::May
        def prompt = "Mill a card?"

        def resolve!
          controller.mill(1)
        end
      end

      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def call
          game.choices.add(MillChoice.new(actor: actor))
        end
      end

      def event_handlers = { Events::BeginningOfUpkeep => UpkeepTrigger }
    end
  end
end
