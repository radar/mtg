module Magic
  module Cards
    TeapotSlinger = Creature("Teapot Slinger") do
      cost generic: 3, red: 1
      creature_type("Raccoon Warrior")
      keywords :menace
      power 3
      toughness 4
    end

    class TeapotSlinger < Creature
      # Whenever you expend 4, this creature deals 2 damage to each opponent.
      class ExpendTrigger < TriggeredAbility::Expend
        def threshold = 4

        def call
          opponents.each { |opponent| deal_damage(2, to: opponent) }
        end
      end

      def event_handlers = super.merge(ExpendTrigger.handlers)
    end
  end
end
