module Magic
  module Cards
    AnafenzaUnyieldingLineage = Creature("Anafenza, Unyielding Lineage") do
      cost generic: 2, white: 1
      legendary_creature_type("Spirit Soldier")
      keywords :flash, :first_strike
      power 2
      toughness 2
    end

    class AnafenzaUnyieldingLineage < Creature
      class CreatureDiesTrigger < TriggeredAbility
        def should_perform?
          you? && event.permanent != actor && !event.permanent.token?
        end

        def call
          game.choices.add(Magic::Choice::Endure.new(actor: actor, amount: 2))
        end
      end

      def event_handlers = { Events::CreatureDied => CreatureDiesTrigger }
    end
  end
end
