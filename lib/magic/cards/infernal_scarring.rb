module Magic
  module Cards
    InfernalScarring = Aura("Infernal Scarring") do
      cost generic: 1, black: 1
    end

    class InfernalScarring < Aura
      enchant "Creature"

      def target_choices = battlefield.creatures

      class PowerModification < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 0
        applies_to_target
      end

      def static_abilities = [PowerModification]

      # "Enchanted creature ... has 'When this creature dies, draw a card.'" Its controller draws.
      class EnchantedCreatureDiesTrigger < TriggeredAbility
        def should_perform? = event.permanent == actor.attached_to

        def call
          trigger_effect(:draw_cards, player: event.permanent.controller)
        end
      end

      def event_handlers = { Events::CreatureDied => EnchantedCreatureDiesTrigger }
    end
  end
end
