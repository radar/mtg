module Magic
  module Cards
    InnocuousRat = Creature("Innocuous Rat") do
      cost generic: 1, black: 1
      creature_type "Rat"
      power 1
      toughness 1
    end

    class InnocuousRat < Creature
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
