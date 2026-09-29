module Magic
  module Cards
    ChampionOfThePath = Creature("Champion of the Path") do
      cost generic: 3, red: 1
      creature_type("Elemental Sorcerer")
      power 7
      toughness 3
    end

    class ChampionOfThePath < Creature
      # As an additional cost to cast this spell, behold an Elemental and exile it.
      def additional_costs
        [Costs::Behold.new(self, type: "Elemental", exile: true)]
      end

      # Whenever another Elemental you control enters, it deals damage equal to its power to each
      # opponent.
      class ElementalEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          under_your_control? && event.permanent != actor && event.permanent.type?("Elemental")
        end

        def call
          elemental = event.permanent
          game.opponents(controller).each do |opponent|
            elemental.trigger_effect(:deal_damage, source: elemental, target: opponent, damage: elemental.power)
          end
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => ElementalEntersTrigger }

      # When this creature leaves the battlefield, return the exiled card to its owner's hand.
      def ltb_triggers = [Behold::ReturnExiledCardTrigger]
    end
  end
end
