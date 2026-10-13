module Magic
  module Cards
    StarAthlete = Creature("Star Athlete") do
      cost generic: 1, red: 2
      creature_type "Human Warrior"
      keywords :menace
      power 3
      toughness 2
      blitz generic: 3, red: 1
    end

    class StarAthlete < Creature
      # The permanent's controller sacrifices it (accepting) or takes 5 damage (declining).
      class SacrificeOrDamageChoice < Magic::Choice::May
        def initialize(actor:, permanent:)
          super(actor: actor)
          @permanent = permanent
        end

        def chooser = @permanent.controller

        def prompt = "Sacrifice #{@permanent.name}? If you don't, #{actor.name} deals 5 damage to you."

        def resolve!
          @permanent.sacrifice!
        end

        def decline!
          deal_damage 5, to: @permanent.controller
        end
      end

      class TargetChoice < Magic::Choice::Targeted
        def prompt = "Choose up to one target nonland permanent. Its controller may sacrifice it. If they don't, #{actor.name} deals 5 damage to them."

        def choices = battlefield.permanents.reject(&:land?)

        def choice_amount = 1

        def resolve!(target:)
          game.add_choice(SacrificeOrDamageChoice.new(actor: actor, permanent: target))
        end
      end

      # "Whenever this creature attacks, choose up to one target nonland permanent. Its controller may sacrifice it. If they
      # don't, this creature deals 5 damage to that player."
      class AttacksTrigger < TriggeredAbility
        def should_perform? = event.attacker == actor

        def call
          game.add_choice(TargetChoice.new(actor: actor))
        end
      end

      def event_handlers = { Events::CreatureAttacked => AttacksTrigger }
    end
  end
end
