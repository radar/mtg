module Magic
  module Cards
    ThundertrapTrainer = Creature("Thundertrap Trainer") do
      cost generic: 1, blue: 1
      creature_type("Otter Wizard")
      power 1
      toughness 2
      offspring generic: 4
    end

    class ThundertrapTrainer < Creature
      # When this creature enters, look at the top four cards of your library. You may reveal a noncreature,
      # nonland card from among them and put it into your hand. Put the rest on the bottom of your library in
      # a random order.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          filter = ->(card) { !card.creature? && !card.land? }
          game.choices.add(Magic::Choice::LookAtTopCards.new(actor: actor, amount: 4, filter: filter))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
