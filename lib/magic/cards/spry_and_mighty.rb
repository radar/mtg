module Magic
  module Cards
    SpryAndMighty = Sorcery("Spry and Mighty") do
      cost generic: 4, green: 1
    end

    class SpryAndMighty < Sorcery
      # "Choose exactly two creatures you control. You draw X cards and the chosen
      # creatures get +X/+X and gain trample until end of turn, where X is the difference
      # between the chosen creatures' powers." Not targeted: chosen as it resolves.
      class CreaturesChoice < Magic::Choice
        class InvalidChoice < StandardError; end

        def choices = battlefield.controlled_by(controller).creatures

        def resolve!(targets:)
          unless targets.size == 2 && targets.uniq.size == 2 && targets.all? { choices.include?(_1) }
            raise InvalidChoice, "choose exactly two creatures you control"
          end

          x = (targets[0].power - targets[1].power).abs
          trigger_effect(:draw_cards, number_to_draw: x) if x.positive?
          targets.each do |creature|
            trigger_effect(:modify_power_toughness, target: creature, power: x, toughness: x)
            trigger_effect(:grant_keyword, target: creature, keyword: :trample)
          end
        end
      end

      def resolve!
        choice = CreaturesChoice.new(actor: self)
        game.add_choice(choice) if choice.choices.count >= 2
      end
    end
  end
end
