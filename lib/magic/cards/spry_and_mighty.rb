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
          draw_cards(x) if x.positive?
          targets.each do |creature|
            pump(creature, x, x)
            give_keyword(creature, :trample)
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
