module Magic
  module Cards
    UntimelyMalfunction = Instant("Untimely Malfunction") do
      cost generic: 1, red: 1
    end

    class UntimelyMalfunction < Instant
      # "Destroy target artifact."
      class DestroyArtifact < Mode
        def target_choices = battlefield.artifacts

        def resolve!(target:)
          trigger_effect(:destroy_target, target:)
        end
      end

      # "Change the target of target spell or ability with a single target."
      class ChangeTarget < Mode
        class RetargetChoice < Magic::Choice::Targeted
          def initialize(actor:, target_item:)
            super(actor: actor)
            @target_item = target_item
          end

          def choice_amount = 1

          def choices
            if @target_item.respond_to?(:card)
              method = @target_item.card.method(:target_choices)
              method.arity == 1 ? @target_item.card.target_choices(@target_item.player) : @target_item.card.target_choices
            else
              @target_item.ability.target_choices
            end
          end

          def resolve!(target:)
            @target_item.targeting(target)
          end
        end

        def target_choices
          (game.stack.spells + game.stack.abilities).select do |item|
            item.respond_to?(:targeting) && item.targets.size == 1
          end
        end

        def resolve!(target:)
          choice = RetargetChoice.new(actor: card, target_item: target)
          game.choices.add(choice) if choice.choices.any?
        end
      end

      # "One or two target creatures can't block this turn."
      class CantBlock < Mode
        def target_choices = battlefield.creatures

        def resolve!(targets:)
          targets.first(2).each(&:prevent_blocking!)
        end
      end

      modes DestroyArtifact, ChangeTarget, CantBlock
      choose_modes 1
    end
  end
end
