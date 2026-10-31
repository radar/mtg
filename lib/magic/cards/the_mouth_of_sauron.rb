module Magic
  module Cards
    TheMouthOfSauron = Creature("The Mouth of Sauron") do
      cost generic: 3, blue: 1, black: 1
      legendary_creature_type "Human Advisor"
      power 3
      toughness 4
    end

    class TheMouthOfSauron < Creature
      # "When The Mouth of Sauron enters, target player mills three cards. Then amass Orcs X, where X is the number of
      # instant and sorcery cards in that player's graveyard." X is counted after the mill.
      class MillChoice < Magic::Choice::Targeted
        def choices = game.players

        def choice_amount = 1

        def resolve!(target:)
          target.mill(3)
          game.tick!
          x = target.graveyard.cards.count { _1.type?("Instant") || _1.type?("Sorcery") }
          Magic::Amass.call(source: actor, controller: controller, amount: x, subtype: "Orc")
        end

        def decline! = nil
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform? = event.permanent == actor

        def call
          game.add_choice(MillChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
