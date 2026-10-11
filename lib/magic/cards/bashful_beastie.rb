module Magic
  module Cards
    BashfulBeastie = Creature("Bashful Beastie") do
      cost generic: 4, green: 1
      creature_type "Beast"
      power 5
      toughness 4
    end

    class BashfulBeastie < Creature
      # "When this creature dies, manifest dread."
      class DiesTrigger < TriggeredAbility::Death
        def call
          Magic::Choice::ManifestDread.perform(actor: actor)
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
