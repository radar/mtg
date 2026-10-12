module Magic
  module Cards
    ValleyFloodcaller = Creature("Valley Floodcaller") do
      cost generic: 2, blue: 1
      creature_type("Otter Wizard")
      keywords :flash
      power 2
      toughness 2
    end

    class ValleyFloodcaller < Creature
      TYPES = %w[Bird Frog Otter Rat].freeze

      # You may cast noncreature spells as though they had flash.
      class NoncreatureFlash < Abilities::Static::GrantFlash
        def grants_flash?(card, player) = player == controller && !card.creature?
      end

      def static_abilities = [NoncreatureFlash]

      # Whenever you cast a noncreature spell, Birds, Frogs, Otters, and Rats you control get +1/+1 until end of
      # turn. Untap them.
      class CastTrigger < TriggeredAbility::SpellCast
        def should_perform? = event.player == controller && !spell.creature?

        def call
          battlefield.controlled_by(controller).creatures.select { |creature| ValleyFloodcaller::TYPES.any? { creature.type?(_1) } }.each do |creature|
            pump(creature, 1, 1)
            creature.untap!
          end
        end
      end

      def event_handlers = super.merge(Events::SpellCast => CastTrigger)
    end
  end
end
