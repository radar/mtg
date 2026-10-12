module Magic
  module Cards
    class SeasonOfGathering < Sorcery
      card_name "Season of Gathering"
      cost generic: 4, green: 2

      # {P} -- Put a +1/+1 counter on a creature you control. It gains vigilance and trample until end of turn.
      class GrowCreature < Mode
        points 1

        def target_choices = battlefield.controlled_by(controller).creatures

        def resolve!(target:)
          trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 1)
          trigger_effect(:grant_keyword, target: target, keyword: :vigilance)
          trigger_effect(:grant_keyword, target: target, keyword: :trample)
        end
      end

      # {P}{P} -- Choose artifact or enchantment. Destroy all permanents of the chosen type.
      class DestroyType < Mode
        points 2

        class TypeChoice < Magic::Choice
          def choices = %w[Artifact Enchantment]

          def resolve!(type:)
            raise ArgumentError, "choose Artifact or Enchantment" unless choices.include?(type)

            battlefield.by_any_type(type).each { trigger_effect(:destroy_target, target: _1) }
          end
        end

        def resolve!
          game.choices.add(TypeChoice.new(actor: card))
        end
      end

      # {P}{P}{P} -- Draw cards equal to the greatest power among creatures you control.
      class DrawCards < Mode
        points 3

        def resolve!
          power = battlefield.controlled_by(controller).creatures.map(&:power).max.to_i
          trigger_effect(:draw_cards, number_to_draw: power) if power.positive?
        end
      end

      modes GrowCreature, DestroyType, DrawCards
      modes_budget 5
    end
  end
end
