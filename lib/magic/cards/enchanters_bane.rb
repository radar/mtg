module Magic
  module Cards
    EnchantersBane = Enchantment("Enchanter's Bane") do
      cost generic: 1, red: 1
    end

    class EnchantersBane < Enchantment
      # The enchantment's controller either sacrifices it (accepting the choice) or takes damage equal to its mana value
      # (declining).
      class SacrificeOrDamageChoice < Magic::Choice::May
        def initialize(actor:, enchantment:)
          super(actor: actor)
          @enchantment = enchantment
        end

        def chooser = @enchantment.controller

        def prompt = "Sacrifice #{@enchantment.name}? If you don't, it deals #{@enchantment.mana_value} damage to you."

        def resolve!
          @enchantment.sacrifice!
        end

        def decline!
          deal_damage @enchantment.mana_value, to: @enchantment.controller, source: @enchantment
        end
      end

      class TargetChoice < Magic::Choice::Targeted
        def prompt = "Choose target enchantment. It deals damage equal to its mana value to its controller unless they sacrifice it."

        def choices = battlefield.permanents.select(&:enchantment?)

        def choice_amount = 1

        def resolve!(target:)
          game.add_choice(SacrificeOrDamageChoice.new(actor: actor, enchantment: target))
        end
      end

      # "At the beginning of your end step, target enchantment deals damage equal to its mana value to its controller unless
      # that player sacrifices it."
      class EndStepTrigger < TriggeredAbility
        def should_perform? = event.active_player == controller

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::BeginningOfEndStep => EndStepTrigger }
    end
  end
end
