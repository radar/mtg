module Magic
  module Cards
    ShagratLootBearer = Creature("Shagrat, Loot Bearer") do
      cost generic: 2, black: 1, red: 1
      legendary_creature_type "Orc Soldier"
      power 4
      toughness 4
    end

    class ShagratLootBearer < Creature
      # "Whenever Shagrat attacks, attach up to one target Equipment to it. Then amass Orcs X, where X is the number
      # of Equipment attached to Shagrat." Control of the Equipment does not change.
      class AttachChoice < Magic::Choice::Targeted
        def initialize(actor:, shagrat:)
          @shagrat = shagrat
          super(actor: actor)
        end

        def choice_amount = 0..1

        def choices = game.battlefield.permanents.select { _1.type?("Equipment") }

        def resolve!(target: nil)
          target&.attach_to!(@shagrat)
          game.tick!
          amass
        end

        def decline! = amass

        private

        def amass
          x = @shagrat.attachments.count { _1.type?("Equipment") }
          Magic::Amass.call(source: actor, controller: controller, amount: x, subtype: "Orc")
        end
      end

      class AttackTrigger < TriggeredAbility
        def should_perform? = event.attacker == actor

        def call
          choice = AttachChoice.new(actor: actor, shagrat: event.attacker)
          if choice.choices.any?
            game.add_choice(choice)
          else
            choice.decline!
          end
        end
      end

      def event_handlers = { Events::CreatureAttacked => AttackTrigger }
    end
  end
end
