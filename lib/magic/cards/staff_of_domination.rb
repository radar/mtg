module Magic
  module Cards
    StaffOfDomination = Artifact("Staff of Domination") do
      cost generic: 3
    end

    class StaffOfDomination < Artifact
      class UntapSelf < Magic::ActivatedAbility
        costs "{1}"

        def resolve!
          source.untap!
        end
      end

      class GainLife < Magic::ActivatedAbility
        costs "{2}, {T}"

        def resolve!
          trigger_effect(:gain_life, life: 1)
        end
      end

      class UntapCreature < Magic::ActivatedAbility
        costs "{3}, {T}"

        def target_choices
          creatures
        end

        def resolve!(target:)
          target.untap!
        end
      end

      class TapCreature < Magic::ActivatedAbility
        costs "{4}, {T}"

        def target_choices
          creatures
        end

        def resolve!(target:)
          trigger_effect(:tap, target: target)
        end
      end

      class DrawCard < Magic::ActivatedAbility
        costs "{5}, {T}"

        def resolve!
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      def activated_abilities
        [UntapSelf, GainLife, UntapCreature, TapCreature, DrawCard]
      end
    end
  end
end
