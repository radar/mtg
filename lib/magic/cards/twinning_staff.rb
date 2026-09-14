module Magic
  module Cards
    TwinningStaff = Artifact("Twinning Staff") do
      cost generic: 3
    end

    class TwinningStaff < Artifact
      class CopyMultiplier < Abilities::Static::CopyMultiplier
      end

      def static_abilities
        [CopyMultiplier]
      end

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{7}, {T}"

        def single_target?
          true
        end

        def target_choices
          game.stack.spells.select { |spell| (spell.card.instant? || spell.card.sorcery?) && spell.card.controller == controller }
        end

        def resolve!(target:)
          Magic::CopyEffect.resolve_with_choice!(actor: source, receiver: target.card, targets: target.targets)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
