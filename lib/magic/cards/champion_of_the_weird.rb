module Magic
  module Cards
    ChampionOfTheWeird = Creature("Champion of the Weird") do
      cost generic: 3, black: 1
      creature_type("Goblin Berserker")
      power 5
      toughness 5
    end

    class ChampionOfTheWeird < Creature
      # As an additional cost to cast this spell, behold a Goblin and exile it.
      def additional_costs
        [Costs::Behold.new(self, type: "Goblin", exile: true)]
      end

      # Pay 1 life, Blight 2: Target opponent blights 2. Activate only as a sorcery.
      class BlightAbility < Magic::ActivatedAbility
        costs "Pay 1 life, Blight 2"

        def requirements_met?
          game.can_cast_sorcery?(controller)
        end

        def single_target?
          true
        end

        def target_choices
          game.opponents(controller)
        end

        def resolve!(target:)
          choice = Magic::Choice::Blight.new(actor: source, amount: 2, player: target)
          game.choices.add(choice) if choice.choices.any?
        end
      end

      def activated_abilities = [BlightAbility]

      # When this creature leaves the battlefield, return the exiled card to its owner's hand.
      def ltb_triggers = [Behold::ReturnExiledCardTrigger]
    end
  end
end
