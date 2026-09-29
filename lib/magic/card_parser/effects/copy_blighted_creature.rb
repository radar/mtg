# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Create a tapped and attacking token that's a copy of the blighted creature, except it has
      # 'At the beginning of the end step, sacrifice this token.'" -- only after a blight choice,
      # whose `resolve!(target:)` receives the blighted creature as `args[:target]`.
      class CopyBlightedCreature < Data.define
        include Effect

        LINE = /\ACreate a tapped and attacking token that's a copy of the blighted creature, except it has "At the beginning of the end step, sacrifice this token\.?"\.?\z/

        def self.parse(text)
          new if LINE.match?(text)
        end

        def definitions
          "class SacrificeTokenTrigger < TriggeredAbility::BeginningOfEndStep\n  def call = actor.sacrifice!\nend\n"
        end

        def resolve_call
          <<~RUBY.chomp
            token = Permanent.resolve(game: game, owner: controller, card: args[:target].copiable_card, token: true, copy: true, cast: false, enters_tapped: true)
            token.register_turn_trigger(Events::BeginningOfEndStep, SacrificeTokenTrigger)
            game.current_turn.combat.declare_attacker(token, target: game.current_turn.attacks.find { _1.attacker == actor }&.target)
          RUBY
        end
      end
    end
  end
end
