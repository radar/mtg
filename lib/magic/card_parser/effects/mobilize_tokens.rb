# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # Mobilize N: "Create N tapped and attacking 1/1 red Warrior creature tokens. Sacrifice them at the
      # beginning of the next end step." The tokens attack whatever the mobilizing creature attacks, and
      # each gets a one-turn beginning-of-end-step trigger that sacrifices it.
      class MobilizeTokens < Data.define(:amount)
        include Effect

        LINE = /\ACreate (?<amount>\w+) tapped and attacking 1\/1 red Warrior creature tokens?\. Sacrifice (?:it|them) at the beginning of the next end step\.?\z/i

        def self.parse(text)
          new(amount: Number.parse($~[:amount])) if LINE.match(text)
        end

        def token = CreateToken.new(amount:, power: 1, toughness: 1, colors: [:red], subtypes: "Warrior", artifact: false, keywords: [])

        def definitions
          [token.definitions, "class SacrificeTokenTrigger < TriggeredAbility::BeginningOfEndStep\n  def call = actor.sacrifice!\nend\n"].join("\n")
        end

        def resolve_call
          <<~RUBY.chomp
            Array(trigger_effect(:create_token, token_class: #{token.token_const}, amount: #{amount}, enters_tapped: true, attacking: true, attack_target: game.current_turn.attacks.find { _1.attacker == #{THIS} }&.target)).each do |token|
              token.register_turn_trigger(Events::BeginningOfEndStep, SacrificeTokenTrigger)
            end
          RUBY
        end
      end
    end
  end
end
