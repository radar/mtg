module Magic
  module Cards
    AniktheaHandOfErebos = Creature("Anikthea, Hand of Erebos") do
      type T::Super::Legendary, T::Enchantment, T::Creature, T::Creatures["Demigod"]
      cost generic: 2, white: 1, black: 1, green: 1
      power 4
      toughness 4
      keywords :menace
    end

    class AniktheaHandOfErebos < Creature
      class OtherEnchantmentCreatureMenace < Abilities::Static::KeywordGrant
        keyword_grants Keywords::MENACE

        applicable_targets do
          source.controller.creatures.enchantments - [source]
        end
      end

      # "Exile up to one target non-Aura enchantment card from your graveyard. Create a token that's a copy of that
      # card, except it's a 3/3 black Zombie creature in addition to its other types." The card itself becomes the
      # token (so it leaves the graveyard), and taking none is allowed.
      class GraveyardChoice < Magic::Choice::May
        attr_reader :choices

        def initialize(actor:)
          @choices = actor.controller.graveyard.cards.enchantments
            .reject { |card| card.is_a?(Cards::Aura) }
          super
        end

        def resolve!(target: nil)
          return unless target

          # A token's card is never removed from its zone by Permanent.resolve, so exile it here.
          target.exile!
          token = Permanent.resolve(
            game: game,
            owner: controller,
            card: target,
            token: true,
          )
          token.add_types(T::Creature, T::Creatures["Zombie"], until_eot: false)
          token.modify_base_power(3, until_eot: false)
          token.modify_base_toughness(3, until_eot: false)
          token.change_colors!([:black], until_eot: false)
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
