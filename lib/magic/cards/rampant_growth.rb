module Magic
  module Cards
    RampantGrowth = Sorcery("Rampant Growth") do
      cost generic: 1, green: 1
    end

    class RampantGrowth < Sorcery
      def target_choices
        controller.library.basic_lands
      end

      class Effect < Effects::TargetedEffect
        def resolve(target)
          land = target.resolve!(source.controller, enters_tapped: true)
          source.controller.shuffle!
        end
      end

      def resolve!(controller)
        game.add_effect(Effect.new(source: self))

        super
      end
    end
  end
end
