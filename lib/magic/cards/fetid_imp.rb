module Magic
  module Cards
    FetidImp = Creature("Fetid Imp") do
      cost generic: 1, black: 1
      creature_type("Imp")
      keywords :flying
      power 1
      toughness 2
    end

    class FetidImp < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{B}"

        def resolve!
          give_keyword(source, :deathtouch)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
