module Magic
  module Cards
    AcademyElite = Creature("Academy Elite") do
      cost generic: 3, blue: 1
      creature_type("Human Wizard")
      power 0
      toughness 0
    end

    class AcademyElite < Creature
      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          counters = game.graveyard_cards.by_any_type(T::Instant, T::Sorcery).count
          permanent.add_counter(Counters::Plus1Plus1, amount: counters)
        end
      end

      def etb_triggers = [ETB]
    end

  end
end
