module Magic
  module Cards
    DeflectingSwat = Instant("Deflecting Swat") do
      cost generic: 2, red: 1
    end

    class DeflectingSwat < Instant
      def single_target?
        true
      end

      def target_choices
        (game.stack.spells + game.stack.abilities).select do |item|
          item.respond_to?(:targeting) && item.targets.any?
        end
      end

      def resolve!(target:)
        choice = RetargetChoice.new(actor: self, target_item: target)
        game.choices.add(MayRetargetChoice.new(actor: self, target_item: target)) if choice.choices.any?
      end

      class RetargetChoice < Magic::Choice::Targeted
        def initialize(actor:, target_item:)
          super(actor: actor)
          @target_item = target_item
        end

        def choice_amount
          1
        end

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

      class MayRetargetChoice < Magic::Choice::May
        def initialize(actor:, target_item:)
          super(actor: actor)
          @target_item = target_item
        end

        def resolve!
          game.choices.add(RetargetChoice.new(actor: actor, target_item: @target_item))
        end
      end
    end
  end
end
