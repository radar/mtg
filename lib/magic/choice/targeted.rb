module Magic
  class Choice
    class Targeted < Choice
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
