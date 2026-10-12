module Magic
  module Cards
    HiddenGrotto = Card("Hidden Grotto") do
      type T::Land
    end

    class HiddenGrotto < Card
      # When this land enters, surveil 1.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::Surveil.new(actor: actor, amount: 1))
        end
      end

      def etb_triggers = [EntersTrigger]

      # {T}: Add {C}.
      class ColorlessMana < Magic::TapManaAbility
        choices :colorless
      end

      # {1}, {T}: Add one mana of any color.
      class AnyColorMana < Magic::ManaAbility
        costs "{1}, {T}"
        choices :all
      end

      def activated_abilities = [ColorlessMana, AnyColorMana]
    end
  end
end
