# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # Replacement effects on cards going to a graveyard:
      #
      #   If ~ would be put into a graveyard from anywhere, reveal ~ and shuffle it into its owner's library
      #   instead.   (Darksteel Colossus, Progenitus)
      #   If an instant or sorcery card would be put into a graveyard from anywhere, exile it instead.
      #   (Dryad Militant)
      #
      # The first is on the card itself, so it also works away from the battlefield (`zone_replacement_effects`,
      # which `Game::ReplacementEffectSources` reads for cards in hand, library, graveyard, exile and on the
      # stack) and, for the permanent, on `Effects::MovePermanentZone`. The second is a battlefield replacement
      # on `Effects::MoveCardZone`, so it covers a spell resolving, a discard and milling, for either player.
      class GraveyardReplacement < Data.define(:kind, :types)
        include Rule

        SELF = /\AIf ~ would be put into a graveyard from anywhere, reveal ~ and shuffle it into its owner's library instead\.?\z/
        TYPES = /(?<types>(?:instant|sorcery|creature|artifact|enchantment|land|planeswalker)(?: or (?:instant|sorcery|creature|artifact|enchantment|land|planeswalker))*)/
        EXILE = /\AIf an? #{TYPES} card would be put into a graveyard from anywhere, exile it instead\.?\z/

        def self.parse(line)
          return new(kind: :shuffle, types: nil) if SELF.match?(line)

          new(kind: :exile, types: $~[:types].split(" or ").map(&:capitalize)) if EXILE.match(line)
        end

        def initialize(kind:, types: nil) = super

        def kinds = kind == :shuffle ? %i[creature artifact enchantment] : PERMANENT_KINDS

        def body_source
          kind == :shuffle ? shuffle_source : exile_source
        end

        private

        def shuffle_source
          <<~RUBY
            class ShuffleIntoLibraryInstead < ReplacementEffect
              def applies?(effect)
                effect.target == receiver && effect.to.graveyard?
              end

              def call(effect) = Effects::ShuffleIntoLibrary.new(source: receiver, target: effect.target)
            end

            def replacement_effects = { Effects::MovePermanentZone => ShuffleIntoLibraryInstead }

            def zone_replacement_effects = { Effects::MoveCardZone => ShuffleIntoLibraryInstead }
          RUBY
        end

        def exile_source
          <<~RUBY
            class ExileInsteadOfGraveyard < ReplacementEffect
              def applies?(effect)
                effect.to.graveyard? && effect.target.respond_to?(:any_type?) && effect.target.any_type?(#{types.map(&:inspect).join(', ')})
              end

              def call(effect) = Effects::ExileCard.new(source: receiver, target: effect.target)
            end

            def replacement_effects = { Effects::MoveCardZone => ExileInsteadOfGraveyard }
          RUBY
        end
      end
    end
  end
end
