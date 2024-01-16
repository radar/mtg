module Magic
  module Cards
    class FabledPassage < Land
      NAME = "Fabled Passage"

      def target_choices(receiver)
        receiver.controller.library.basic_lands
      end

      class Effect < Effects::SearchLibraryForBasicLand
        def resolve(target)
          land = super
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
          game.add_effect(Effect.new(source: source, enters_tapped: true))
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
