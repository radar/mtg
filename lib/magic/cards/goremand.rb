module Magic
  module Cards
    Goremand = Creature("Goremand") do
      cost generic: 4, black: 2
      creature_type("Demon")
      keywords :flying, :trample
      power 5
      toughness 5
    end

    class Goremand < Creature
      # Sacrifice a creature as an additional cost to cast this card.
      def additional_costs
        [Costs::Sacrifice.new(self, (controller || owner).creatures)]
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class SacrificeChoice < Magic::Choice::Targeted
          def initialize(actor:, player:)
            @player = player
            super(actor: actor)
          end

          def choices
            battlefield.controlled_by(@player).by_any_type("Creature")
          end

          def choice_amount = 1

          def resolve!(target:)
            target.sacrifice!
          end
        end

        def call
          game.opponents(controller).each do |opponent|
            choice = SacrificeChoice.new(actor: actor, player: opponent)
            game.choices.add(choice) if choice.choices.any?
          end
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
