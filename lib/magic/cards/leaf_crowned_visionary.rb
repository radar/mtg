module Magic
  module Cards
    class LeafCrownedVisionary < Creature
      card_name "Leaf-Crowned Visionary"
      cost "{G}{G}"
      creature_type "Elf Druid"
      power 1
      toughness 1

      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        def initialize(source:)
          @source = source
        end

        def power
          1
        end

        def toughness
          1
        end

        def applicable_targets
          source.controller.creatures.by_type("Elf") - [source]
        end
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

      # Whenever you cast an Elf spell,
      # you may pay {G}. If you do, draw a card.
      def event_handlers
        {
          Events::SpellCast => ->(receiver, event) do
            return if event.player != receiver.controller
            return unless event.spell.type?("Elf")

            game
              .choices
              .add(
                Magic::Cards::LeafCrownedVisionary::Choice.new(owner: receiver.controller)
              )
          end
        }
      end
    end
  end
end
