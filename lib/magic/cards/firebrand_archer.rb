module Magic
  module Cards
    FirebrandArcher = Creature("Firebrand Archer") do
      power 2
      toughness 1
      cost generic: 1, red: 1
      creature_type "Human Archer"
    end

    class FirebrandArcher < Creature
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && !spell.creature?
        end

        def call
          opponents.each { |opponent| actor.trigger_effect(:deal_damage, damage: 1, target: opponent) }
        end
      end

      def event_handlers
        { Events::SpellCast => SpellCastTrigger }
      end
    end
  end
end
