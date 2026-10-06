module Magic
  module Cards
    FellTheMighty = Sorcery("Fell the Mighty") do
      cost generic: 4, white: 1
    end

    class FellTheMighty < Sorcery
      def target_choices
        battlefield.creatures
      end

      # "Destroy all creatures with power greater than target creature's power."
      def resolve!(target:)
        power = target.power
        battlefield.creatures.select { |creature| creature.power > power }.each do |creature|
          trigger_effect(:destroy_target, target: creature)
        end
      end
    end
  end
end
