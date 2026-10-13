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
          [controller].each { deal_damage(1, to: _1) }
          draw_card
        end
      end

      def event_handlers = super.merge({ Events::CreatureDied => CreatureDiesTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
