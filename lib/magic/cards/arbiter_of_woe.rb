module Magic
  module Cards
    ArbiterOfWoe = Creature("Arbiter of Woe") do
      cost generic: 4, black: 2
      creature_type("Demon")
      keywords :flying
      power 5
      toughness 4
    end

    class ArbiterOfWoe < Creature
      # Sacrifice a creature as an additional cost to cast this card.
      def additional_costs
        [Costs::Sacrifice.new(self, (controller || owner).creatures)]
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.opponents(controller).each { |opponent| game.add_choice(Magic::Choice::Discard.new(player: opponent)) }
          game.opponents(controller).each { trigger_effect(:lose_life, target: _1, life: 2) }
          trigger_effect(:draw_card)
          trigger_effect(:gain_life, target: controller, life: 2)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
