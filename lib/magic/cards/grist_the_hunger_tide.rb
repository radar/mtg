module Magic
  module Cards
    class GristTheHungerTide < Planeswalker
      card_name "Grist, the Hunger Tide"
      type T::Super::Legendary, T::Planeswalker, "Grist", T::Creature, T::Creatures["Insect"]
      cost generic: 1, black: 1, green: 1
      loyalty 3
      power 1
      toughness 1

      class TypeModification < Abilities::Static::TypeRemoval
        def initialize(source:)
          @source = source
        end

        def type_removal
          [T::Creature, T::Creatures["Insect"]]
        end

        def applicable_targets = [source]
      end

      def static_abilities = [TypeModification]

      class InsectToken < Token
        token_name "Insect"
        creature_type "Insect"
        colors :black, :green
        power 1
        toughness 1
      end

      class LoyaltyAbility1 < LoyaltyAbility
        def loyalty_change = 1

        def resolve!
          loop do
            source.trigger_effect(:create_token, token_class: InsectToken)
            milled = controller.mill(1).first
            break unless milled.type?(T::Creatures["Insect"])

            source.change_loyalty!(1)
          end
        end
      end

      class DestroyChoice < Magic::Choice::Targeted
        def choices = battlefield.by_any_type(T::Creature, T::Planeswalker)
        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      class SacrificeChoice < Magic::Choice::Targeted
        def choices = controller.creatures
        def choice_amount = 1

        def resolve!(target:)
          target.sacrifice!

          destroy_choice = DestroyChoice.new(actor: actor)
          game.choices.add(destroy_choice) if destroy_choice.choices.any?
        end
      end

      class MaySacrificeChoice < Magic::Choice::May
        def resolve!
          game.choices.add(SacrificeChoice.new(actor: actor))
        end
      end

      class LoyaltyAbility2 < LoyaltyAbility
        def loyalty_change = -2

        def resolve!
          choice = SacrificeChoice.new(actor: source)
          game.choices.add(MaySacrificeChoice.new(actor: source)) if choice.choices.any?
        end
      end

      class LoyaltyAbility3 < LoyaltyAbility
        def loyalty_change = -5

        def resolve!
          amount = graveyard.creatures.count
          game.opponents(controller).each do |opponent|
            trigger_effect(:lose_life, target: opponent, life: amount)
          end
        end
      end

      def loyalty_abilities
        [
          LoyaltyAbility1,
          LoyaltyAbility2,
          LoyaltyAbility3,
        ]
      end
    end
  end
end
