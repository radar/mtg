module Magic
  module Cards
    MidnightReaper = Creature("Midnight Reaper") do
      cost generic: 2, black: 1
      creature_type("Zombie Knight")
      power 3
      toughness 2
    end

    class MidnightReaper < Creature
      class CreatureDiesTrigger < TriggeredAbility
        def should_perform?
          you? && !event.permanent.token?
        end

        def call
          [controller].each { trigger_effect(:deal_damage, target: _1, damage: 1) }
          trigger_effect(:draw_card)
        end
      end

      def event_handlers = super.merge({ Events::CreatureDied => CreatureDiesTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
