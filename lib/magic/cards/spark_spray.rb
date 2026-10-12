module Magic
  module Cards
    SparkSpray = Instant("Spark Spray") do
      cost red: 1
      cycling red: 1

      def target_choices
        game.any_target
      end

      def single_target?
        true
      end

      def resolve!(target:)
        deal_damage(1, to: target)
      end
    end
  end
end
