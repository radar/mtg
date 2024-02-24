module Magic
  module Actions
    class Cast < Action
      class Mode
        attr_reader :mode, :targets

        def initialize(mode)
          @mode = mode
          @targets = []
        end

        def target_choices
          choices = mode.method(:target_choices)
          choices = choices.arity == 1 ? mode.target_choices(player) : mode.target_choices
        end

        def can_target?(target, index = nil)
          if index
            target_choices[index].include?(target)
          else
            target_choices.include?(target)
          end
        end

        def targeting(*targets)
          if mode.respond_to?(:multi_target?) && mode.multi_target?
            return multi_target(*targets)
          end

          targets.each do |target|
            raise InvalidTarget, "Invalid target for #{mode.class}: #{target}" unless can_target?(target)
          end
          @targets = targets
          self
        end

        def resolve!
          resolver = mode.method(:resolve!)
          args = {}
          args[:target] = targets.first if resolver.parameters.include?([:keyreq, :target])
          args[:targets] = targets if resolver.parameters.include?([:keyreq, :targets])

          mode.resolve!(**args)
        end

      end
    end
  end
end
