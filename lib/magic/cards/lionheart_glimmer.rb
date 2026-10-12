module Magic
  module Cards
    LionheartGlimmer = Creature("Lionheart Glimmer") do
      cost generic: 3, white: 2
      enchantment_creature_type("Cat Glimmer")
      ward generic: 2
      power 2
      toughness 5
    end

    class LionheartGlimmer < Creature
      class YouAttackTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && event.attacks.any?
        end

        def call
          battlefield.controlled_by(controller).creatures.each { |creature| pump(creature, 1, 1) }
        end
      end

      def event_handlers = super.merge({ Events::FinalAttackersDeclared => YouAttackTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
