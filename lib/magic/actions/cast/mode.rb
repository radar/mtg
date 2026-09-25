module Magic
  module Actions
    class Cast < Action
      class Mode
        include Magic::ResolvesWithArgs

        attr_reader :mode, :targets

        def initialize(mode, source: nil, controller: nil)
          @mode = mode
          @source = source
          @controller = controller
          @targets = []
        end

        def target_choices
          choices = mode.method(:target_choices)
          choices = choices.arity == 1 ? mode.target_choices(player) : mode.target_choices
        end

        def can_target?(target, index = nil)
          choices = index ? target_choices[index] : target_choices
          choices.include?(target) && Targetable.targetable_by?(target, source: @source, controller: @controller)
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
          resolve_with_args(mode, target: targets.first, targets: targets)
        end

      end
    end
  end
end
