module Magic
  module Cards
    ThornplateIntimidator = Creature("Thornplate Intimidator") do
      cost generic: 3, black: 1
      creature_type("Rat Rogue")
      power 4
      toughness 3
      offspring generic: 3
    end

    class ThornplateIntimidator < Creature
      # When this creature enters, target opponent loses 3 life unless they sacrifice a nonland permanent of
      # their choice or discard a card.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          opponents.each do |opponent|
            game.choices.add(Magic::Choice::LoseLifeUnless.new(actor: actor, player: opponent, life: 3, discard: true, sacrifice: true))
          end
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
