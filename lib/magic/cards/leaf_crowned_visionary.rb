module Magic
  module Cards
    class LeafCrownedVisionary < Creature
      card_name "Leaf-Crowned Visionary"
      cost "{G}{G}"
      creature_type "Elf Druid"
      power 1
      toughness 1

      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1

        applicable_targets { your.creatures.all("Elf").except(source) }
      end

      class Choice < Magic::Choice
        attr_reader :owner

        def initialize(owner:)
          @owner = owner
        end

        def costs
          @costs ||= [Costs::Mana.new(green: 1)]
        end

        def pay(player:, payment:)
          cost = costs.first
          cost.pay!(player:, payment:)
        end

        def resolve!
          if !costs.all?(&:paid?)
            owner.draw!
          end
        end
      end

      def static_abilities = [PowerAndToughnessModification]

      class SpellCastTrigger < TriggeredAbility::SpellCast
        # Whenever you cast an Elf spell, ...
        def should_perform?
          spell.type?("Elf") && you?
        end

        # you may pay {G}. If you do, draw a card.
        def call
          game
            .choices
            .add(
              Magic::Cards::LeafCrownedVisionary::Choice.new(owner: actor)
            )
        end
      end

      # Whenever you cast an Elf spell,
      # you may pay {G}. If you do, draw a card.
      def event_handlers
        {
          Events::SpellCast => SpellCastTrigger
        }
      end
    end
  end
end
