module Magic
  module Cards
    LivingPhone = Creature("Living Phone") do
      cost generic: 2, white: 1
      artifact_creature_type "Toy"
      power 2
      toughness 1
    end

    class LivingPhone < Creature
      # "When this creature dies, look at the top five cards of your library. You may reveal a creature card with
      # power 2 or less from among them and put it into your hand. Put the rest on the bottom of your library in a
      # random order."
      class DiesTrigger < TriggeredAbility::Death
        def call
          choice = Magic::Choice::LookAtTopCards.new(
            actor: actor, amount: 5, filter: ->(card) { card.creature? && card.class::POWER.is_a?(Integer) && card.class::POWER <= 2 },
            prompt: "Reveal a creature card with power 2 or less from the top five cards of your library and put it into your hand. The rest go on the bottom."
          )
          choice.choices.empty? ? choice.resolve! : game.choices.add(choice)
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
