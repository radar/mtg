module Magic
  module Cards
    CoordinatedClobbering = Sorcery("Coordinated Clobbering") do
      cost green: 1
    end

    class CoordinatedClobbering < Sorcery
      def multi_target? = true

      # Targets are the one or two untapped creatures you control, followed by the creature an opponent controls.
      def target_choices
        mine = battlefield.controlled_by(controller).creatures.untapped
        theirs = battlefield.not_controlled_by(controller).creatures
        [mine + theirs, mine + theirs, mine + theirs]
      end

      def targets_legal?(targets)
        *biters, victim = targets
        return false unless (1..2).cover?(biters.size) && biters.uniq.size == biters.size

        biters.all? { |c| c.controller == controller && c.untapped? } && victim.controller != controller
      end

      def resolve!(targets:)
        *biters, victim = targets
        biters.each(&:tap!)
        biters.each { |biter| biter.bite!(victim) }
      end
    end
  end
end
