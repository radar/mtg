module Magic
  module Effects
    class DestroyTarget
      def self.new(choices:, **args)
        SingleTargetAndResolve.new(
          choices: choices,
          resolution: -> (target) { target.destroy! },
          **args
        )
      end
    end
  end
end
