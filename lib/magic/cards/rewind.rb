module Magic
  module Cards
    Rewind = Instant("Rewind") do
      cost generic: 2, blue: 2

      class Choice < Magic::Choice
        def target_choices
          game.battlefield.lands
        end

        def resolve!(targets:)
          targets.each(&:untap!)
        end
      end

      def target_choices
        game.stack
      end

      def resolve!(target:)
        effect = Effects::CounterSpell.new(source: self, targets: [target]).resolve

        game.choices.add(Choice.new(source: self))

        super()

      end
    end
  end
end
