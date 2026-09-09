module Magic
  module Cards
    GisaGloriousResurrector = Creature("Gisa, Glorious Resurrector") do
      legendary_creature_type "Human Wizard"
      cost generic: 2, black: 2
      power 4
      toughness 4
    end

    class GisaGloriousResurrector < Creature
      class CreatureExileReplacement < ReplacementEffect
        def applies?(effect)
          !!effect.from&.battlefield? && effect.to.graveyard? && effect.target.creature? && effect.target.controller != receiver.controller
        end

        def call(effect)
          Effects::ExilePermanent.new(source: receiver, target: effect.target)
        end
      end

      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def call
          controller.exile.cards.creatures.each do |card|
            card.resolve!
          end
        end
      end

      def replacement_effects
        { Effects::MovePermanentZone => CreatureExileReplacement }
      end

      def event_handlers
        { Events::BeginningOfUpkeep => UpkeepTrigger }
      end
    end
  end
end