# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Target player sacrifices a creature of their choice." / "Target opponent sacrifices
      # an artifact or creature." The player is the target; they choose what to sacrifice,
      # and are skipped if they have nothing to sacrifice.
      class TargetPlayerSacrifices < Data.define(:who, :permanent_types)
        include Effect

        TYPES = EachOpponentSacrifices::TYPES
        LINE = /\ATarget (?<who>player|opponent) sacrifices an? (?<types>(?:#{TYPES.join('|')})(?: or (?:#{TYPES.join('|')}))*)(?: of their choice)?\.?\z/i

        def self.parse(text)
          new(who: $~[:who].downcase, permanent_types: $~[:types].downcase.split(" or ").map(&:capitalize)) if LINE.match(text)
        end

        def target_choices = who == "player" ? "game.players" : "game.opponents(controller)"

        def definitions
          <<~RUBY
            class SacrificeChoice < Magic::Choice::Targeted
              def initialize(actor:, player:)
                @player = player
                super(actor: actor)
              end

              def choices
                battlefield.controlled_by(@player).by_any_type(#{permanent_types.map(&:inspect).join(', ')})
              end

              def choice_amount = 1

              def resolve!(target:)
                target.sacrifice!
              end
            end
          RUBY
        end

        def resolve_call
          <<~RUBY.chomp
            choice = SacrificeChoice.new(actor: #{THIS}, player: target)
            game.choices.add(choice) if choice.choices.any?
          RUBY
        end
      end
    end
  end
end
