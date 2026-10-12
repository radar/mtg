module Magic
  module Cards
    CoruscationMage = Creature("Coruscation Mage") do
      cost generic: 1, red: 1
      creature_type("Otter Wizard")
      power 2
      toughness 2
      offspring generic: 2
    end

    class CoruscationMage < Creature
      # Whenever you cast a noncreature spell, this creature deals 1 damage to each opponent.
      class CastTrigger < TriggeredAbility::SpellCast
        def should_perform? = event.player == controller && !spell.creature?

        def call
          opponents.each { |opponent| trigger_effect(:deal_damage, target: opponent, damage: 1) }
        end
      end

      def event_handlers = super.merge(Events::SpellCast => CastTrigger)
    end
  end
end
