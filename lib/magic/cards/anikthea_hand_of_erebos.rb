module Magic
  module Cards
    AniktheaHandOfErebos = Creature("Anikthea, Hand of Erebos") do
      type T::Super::Legendary, T::Enchantment, T::Creature, T::Creatures["Demigod"]
      cost generic: 2, white: 1, black: 1, green: 1
      power 3
      toughness 3
      keywords :menace
    end

    class AniktheaHandOfErebos < Creature
      class OtherEnchantmentCreatureMenace < Abilities::Static::KeywordGrant
        keyword_grants Keywords::MENACE

        applicable_targets do
          source.controller.creatures.enchantments - [source]
        end
      end

      class GraveyardChoice < Magic::Choice
        attr_reader :choices

        def initialize(actor:)
          @choices = actor.controller.graveyard.cards.enchantments
            .reject { |card| card.is_a?(Cards::Aura) }
          super
        end

        def resolve!(target:)
          token = Permanent.resolve(
            game: game,
            owner: controller,
            card: target,
            token: true,
          )
          token.add_types(T::Creature, T::Creatures["Zombie"])
          token.modify_base_power(3)
          token.modify_base_toughness(3)
          game.tick!
        end
      end

      class EntersOrAttacksTrigger < TriggeredAbility
        def should_perform?
          (event.is_a?(Events::EnteredTheBattlefield) && this?) ||
            (event.is_a?(Events::FinalAttackersDeclared) && event.attacks.any? { |attack| attack.attacker == actor })
        end

        def call
          choices = GraveyardChoice.new(actor: actor)
          game.add_choice(choices) if choices.choices.any?
        end
      end

      def static_abilities = [OtherEnchantmentCreatureMenace]

      def event_handlers
        {
          Events::EnteredTheBattlefield => EntersOrAttacksTrigger,
          Events::FinalAttackersDeclared => EntersOrAttacksTrigger,
        }
      end
    end
  end
end
