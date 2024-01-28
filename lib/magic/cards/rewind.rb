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
        trigger_effect(:counter_spell, target: target)

        game.choices.add(Choice.new(source: self))

        super()

      end
    end
  end
end
