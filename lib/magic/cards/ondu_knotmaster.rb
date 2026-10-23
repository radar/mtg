module Magic
  module Cards
    OnduKnotmaster = Creature("Ondu Knotmaster") do
      cost generic: 2, white: 1, black: 1
      creature_type "Kor Rogue"
      keywords :lifelink
      power 2
      toughness 2
    end

    class OnduKnotmaster < Creature
      # Throw a Line {W}{B}, Sorcery -- Adventure: "Distribute two +1/+1 counters among one or two target creatures."
      adventure white: 1, black: 1

      def target_choices = battlefield.creatures

      def adventure_resolve!(targets:, **)
        targets = targets.uniq.first(2)
        amounts = targets.one? ? [2] : [1, 1]
        targets.zip(amounts).each { |target, amount| add_counter "+1/+1", to: target, amount: amount }
      end

      # "Whenever another modified creature you control dies, put two +1/+1 counters on this creature."
      class ModifiedCreatureDiesTrigger < TriggeredAbility
        def should_perform?
          event.permanent != actor && event.permanent.controller == controller && event.permanent.modified?
        end

        def call
          add_counter "+1/+1", to: actor, amount: 2
        end
      end

      def event_handlers = super.merge({ Events::CreatureDied => ModifiedCreatureDiesTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
