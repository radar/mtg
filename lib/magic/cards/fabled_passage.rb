module Magic
  module Cards
    class FabledPassage < Land
      NAME = "Fabled Passage"
      TYPE_LINE = "Land"

      def target_choices(receiver)
        receiver.controller.library.basic_lands
      end

      class Effect < Effects::TargetedEffect
        def resolve(target)
          land = target.resolve!(source.controller, enters_tapped: true)
          source.controller.shuffle!
          if source.controller.lands.count >= 4
            land.untap!
          end
        end
      end

      class ActivatedAbility < Magic::ActivatedAbility
        def costs
          [
            Costs::Tap.new(source),
            Costs::Sacrifice.new(source),
          ]
        end

        def resolve!
          game.add_effect(Effect.new(source: source))
        end
      end

      def activated_abilities
        [ActivatedAbility]
      end
    end
  end
end
