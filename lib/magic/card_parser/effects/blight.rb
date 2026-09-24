# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Blight 2." (after "you may", or on its own) / "Each opponent blights 1." /
      # "Target opponent blights 2." Blight N puts N -1/-1 counters on a creature that
      # player controls. Blighting yourself is a choice effect (a Choice::Blight, so the
      # effects after it run once you've chosen), and "If you do" effects only run when
      # a creature was there to blight. An opponent blighting is asked in turn.
      class Blight < Data.define(:who, :amount)
        include Effect

        LINE = /\A(?:(?<who>you|each opponent|target opponent) blights?|blight) (?<amount>\d+|\w+)\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text))

          new(who: m[:who]&.downcase || "you", amount: Number.parse(m[:amount]))
        end

        def choice_base = who == "you" ? "Magic::Choice::Blight" : nil
        def choice_class_name = "BlightChoice"
        def choice_args = "amount: #{amount}"
        def choice_guard = "Magic::Choice::Blight.possible?(controller, game)"

        def target_choices = who == "target opponent" ? "game.opponents(controller)" : nil

        def resolve_call
          players = who == "each opponent" ? "game.opponents(controller)" : "[target]"
          <<~RUBY.chomp
            #{players}.each do |opponent|
              choice = Magic::Choice::Blight.new(actor: #{THIS}, amount: #{amount}, player: opponent)
              game.choices.add(choice) if choice.choices.any?
            end
          RUBY
        end
      end
    end
  end
end
