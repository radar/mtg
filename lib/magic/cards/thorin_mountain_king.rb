module Magic
  module Cards
    ThorinMountainKing = Creature("Thorin, Mountain-king") do
      cost generic: 3, red: 1
      legendary_creature_type "Dwarf Noble"
      keywords :trample
      power 3
      toughness 4
    end

    class ThorinMountainKing < Creature
      # "...that creature deals damage equal to its power to up to one target creature."
      class DamageChoice < Magic::Choice::Targeted
        def initialize(actor:, creature:)
          super(actor: actor)
          @creature = creature
        end

        def choices = game.battlefield.creatures.except(@creature)

        def choice_amount = 0..1

        def resolve!(target: nil)
          @creature.bite!(target) if target
        end
      end

      # "...attach any number of target Equipment you control to target creature you control."
      class EquipmentChoice < Magic::Choice
        def initialize(actor:, creature:)
          super(actor: actor)
          @creature = creature
        end

        def choices = controller.permanents.select { _1.type?("Equipment") }

        def resolve!(targets:)
          targets.each { |equipment| equipment.attach_to!(@creature) }
          game.tick!
          return if targets.empty?

          # "When one or more Equipment become attached to that creature this way..."
          game.add_choice(DamageChoice.new(actor: actor, creature: @creature))
        end
      end

      class CreatureChoice < Magic::Choice::Targeted
        def choices = controller.creatures

        def choice_amount = 1

        def resolve!(target:)
          choice = EquipmentChoice.new(actor: actor, creature: target)
          game.choices.add(choice) if choice.choices.any?
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.add_choice(CreatureChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
