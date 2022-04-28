module Magic
  module Effects
    class ExileTarget
      def self.new(choices:, **args)
        SingleTargetAndResolve.new(
          choices: choices,
          resolution: -> (target) { target.exile! },
          **args
        )
      end
    end
  end
end
