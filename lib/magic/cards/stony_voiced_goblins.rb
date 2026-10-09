module Magic
  module Cards
    StonyVoicedGoblins = Creature("Stony-Voiced Goblins") do
      cost generic: 1, black: 1
      creature_type("Goblin Bard")
      power 1
      toughness 1
    end

    class StonyVoicedGoblins < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.opponents(controller).each { |opponent| game.add_choice(Magic::Choice::Discard.new(player: opponent)) }
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
