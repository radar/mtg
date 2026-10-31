module Magic
  module Events
    class DamageDealt
      # `excess` is how much of the damage was beyond what was lethal to a creature (rule 120.10); 0 for players and
      # when the damage was not dealt as damage.
      attr_reader :source, :target, :damage, :combat, :infect, :excess

      def initialize(source:, target:, damage:, combat: false, infect: false, excess: 0)
        @source = source
        @target = target
        @damage = damage
        @combat = combat
        @infect = infect
        @excess = excess
      end

      def combat?
        @combat
      end

      def infect?
        @infect
      end

      def inspect
        "#<Events::DamageDealt source: #{source}, target: #{target}, damage: #{damage}, combat: #{combat?}, infect: #{infect?}>"
      end
    end
  end
end
