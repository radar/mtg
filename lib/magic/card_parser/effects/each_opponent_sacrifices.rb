# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Each opponent sacrifices a creature of their choice." / "Each opponent
      # sacrifices a creature or planeswalker." Each opponent is asked in turn, and
      # skipped if they have nothing to sacrifice.
      class EachOpponentSacrifices < Data.define(:permanent_types)
        include Effect

        TYPES = %w[creature planeswalker artifact enchantment land].freeze
        LINE = /\AEach opponent sacrifices an? (?<types>(?:#{TYPES.join('|')})(?: or (?:#{TYPES.join('|')}))*)(?: of their choice)?\.?\z/i

        def self.parse(text)
          new(permanent_types: $~[:types].downcase.split(" or ").map(&:capitalize)) if LINE.match(text)
        end

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
            game.opponents(controller).each do |opponent|
              choice = SacrificeChoice.new(actor: #{THIS}, player: opponent)
              game.choices.add(choice) if choice.choices.any?
            end
          RUBY
        end
      end
    end
  end
end
