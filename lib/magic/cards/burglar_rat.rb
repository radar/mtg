module Magic
  module Cards
    BurglarRat = Creature("Burglar Rat") do
      cost generic: 1, black: 1
      creature_type("Rat")
      power 1
      toughness 1
    end

    class BurglarRat < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.opponents(controller).each { |opponent| game.add_choice(Magic::Choice::Discard.new(player: opponent)) }
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
