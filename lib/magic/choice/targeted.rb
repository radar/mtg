module Magic
  class Choice
    # A choice of one or more objects. By default it is a target (rule 115): shroud, hexproof and protection keep a
    # permanent or player from being offered (`Targetable`). A choice that only picks ("sacrifice a creature", "choose a
    # card in your hand") overrides `targets?` to be false.
    class Targeted < Choice
      # Wraps `choices` in every subclass, so a subclass's own `choices` (a method or an attr_reader) is filtered too.
      module TargetFilter
        def choices
          legal = super
          return legal unless targets? && legal.respond_to?(:select)

          legal.select { |target| Targetable.targetable_by?(target, source: actor, controller: chooser) }
        end
      end

      def self.inherited(subclass)
        super
        subclass.prepend(TargetFilter)
      end

      # Whether what this choice picks are targets, and so subject to hexproof and the like.
      def targets? = true

      def target_choices
        Magic::Targets::Choices.new(choices: choices, amount: choice_amount)
      end

      def single_target?
        true
      end

      def single_choice?
        target_choices.count == 1
      end
    end
  end
end
