# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Exile another target creature you control, then return that card to the
      # battlefield under its owner's control." The card comes back as a new
      # permanent, so its enters triggers fire again. Like Card#resolve!, the card
      # itself is then moved too: Permanent.resolve alone leaves it listed in exile.
      class Flicker < Data.define(:targets)
        include Effect

        LINE = /\AExile #{PermanentTarget::PATTERN}, then return (?:that card|it) to the battlefield under its owner's control\.?\z/i

        def self.parse(text)
          new(targets: PermanentTarget.choices($~)) if LINE.match(text)
        end

        def target_choices = targets

        def resolve_call
          <<~RUBY.chomp
            card = target.card
            trigger_effect(:exile, target: target)
            Permanent.resolve(game: game, card: card, owner: card.owner, from_zone: card.zone, cast: false)
            card.move_zone!(to: game.battlefield)
          RUBY
        end
      end
    end
  end
end
