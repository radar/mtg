module Magic
  module Cards
    MushroomWatchdogs = Creature("Mushroom Watchdogs") do
      cost generic: 1, green: 1
      creature_type "Dog"
      power 2
      toughness 2
    end

    class MushroomWatchdogs < Creature
      # "Sacrifice a Food: Put a +1/+1 counter on this creature. It gains vigilance until end of turn. Activate only as
      # a sorcery."
      class GrowAbility < Magic::ActivatedAbility
        costs "Sacrifice a Food"
        activate_only_as_sorcery

        def resolve!
          add_counter("+1/+1", to: source)
          give_keyword(source, :vigilance)
        end
      end

      def activated_abilities = [GrowAbility]
    end
  end
end
