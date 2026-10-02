module Magic
  module Cards
    class TempleOfMalice < Land
      NAME = "Temple of Malice"

      enters_tapped

      class ManaAbility < Magic::TapManaAbility
        choices :black, :red
      end

      def activated_abilities = [ManaAbility]

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::Scry.new(actor: actor, amount: 1))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
