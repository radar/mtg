module Magic
  module Cards
    MogisGodOfSlaughter = Creature("Mogis, God of Slaughter") do
      type T::Super::Legendary, T::Enchantment, T::Creature, "God"
      cost generic: 2, black: 1, red: 1
      keywords :indestructible
      power 7
      toughness 5
    end

    class MogisGodOfSlaughter < Creature
      # "As long as your devotion to black and red is less than seven, Mogis isn't a creature."
      class NotACreature < Abilities::Static::TypeRemoval
        def initialize(source:)
          @source = source
        end

        def type_removal = [T::Creature]

        def applicable_targets
          devotion = controller.devotion(:black) + controller.devotion(:red)
          devotion >= 7 ? [] : [source]
        end
      end

      class SacrificeCreatureChoice < Magic::Choice::Targeted
        def initialize(actor:, victim:)
          super(actor: actor)
          @victim = victim
        end

        def chooser = @victim

        def prompt = "Choose a creature you control to sacrifice."

        def targets? = false

        def choices = battlefield.controlled_by(@victim).creatures.to_a

        def choice_amount = 1

        def resolve!(target:)
          target.sacrifice!
        end
      end

      # The player either sacrifices a creature of their choice (accepting) or takes 2 damage (declining).
      class SacrificeOrDamageChoice < Magic::Choice::May
        def initialize(actor:, victim:)
          super(actor: actor)
          @victim = victim
        end

        def chooser = @victim

        def prompt = "Sacrifice a creature? If you don't, #{actor.name} deals 2 damage to you."

        def resolve!
          game.add_choice(SacrificeCreatureChoice.new(actor: actor, victim: @victim))
        end

        def decline!
          deal_damage 2, to: @victim
        end
      end

      # "At the beginning of each opponent's upkeep, Mogis deals 2 damage to that player unless they sacrifice a creature of
      # their choice."
      class UpkeepTrigger < TriggeredAbility
        def should_perform? = opponents.include?(event.player)

        def call
          victim = event.player
          if battlefield.controlled_by(victim).creatures.any?
            game.add_choice(SacrificeOrDamageChoice.new(actor: actor, victim: victim))
          else
            deal_damage 2, to: victim
          end
        end
      end

      def static_abilities = [NotACreature]
      def event_handlers = { Events::BeginningOfUpkeep => UpkeepTrigger }
    end
  end
end
