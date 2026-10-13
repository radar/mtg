module Magic
  module Cards
    class TyvarKell < Planeswalker
      card_name "Tyvar Kell"
      type T::Super::Legendary, T::Planeswalker, "Tyvar"
      cost generic: 2, green: 2
      loyalty 3

      ElfWarriorToken = Token.create "Elf Warrior" do
        creature_type "Elf Warrior"
        power 1
        toughness 1
        colors :green
      end

      # "Elves you control have '{T}: Add {B}.'"
      class BlackManaAbility < Magic::TapManaAbility
        choices :black
      end

      class GrantManaAbility < Abilities::Static::GrantActivatedAbilities
        def applies_to?(permanent)
          permanent.creature? && permanent.type?("Elf") && permanent.controller == controller
        end

        def granted_abilities = [BlackManaAbility]
      end

      def static_abilities = [GrantManaAbility]

      # "+1: Put a +1/+1 counter on up to one target Elf. Untap it. It gains deathtouch until end
      # of turn."
      class PlusOneAbility < LoyaltyAbility
        def loyalty_change = 1
        def description = "Put a +1/+1 counter on up to one target Elf. Untap it. It gains deathtouch until end of turn."

        def target_choices
          battlefield.creatures.select { _1.type?("Elf") }
        end

        def resolve!(target: nil)
          return unless target

          add_counter("+1/+1", to: target)
          target.untap!
          give_keyword(target, :deathtouch)
        end
      end

      # "0: Create a 1/1 green Elf Warrior creature token."
      class ZeroAbility < LoyaltyAbility
        def loyalty_change = 0
        def description = "Create a 1/1 green Elf Warrior creature token."

        def resolve!
          create_token(token:ElfWarriorToken)
        end
      end

      # "You get an emblem with 'Whenever you cast an Elf spell, it gains haste until end of turn and
      # you draw two cards.'"
      class Emblem < Magic::Emblem
        def receive_event(event)
          return unless event.is_a?(Events::SpellCast) && event.player == owner && event.spell.type?("Elf")

          game.stack.spells.find { _1.card == event.spell }&.gain_haste_on_resolve!
          draw_cards(2, player: owner)
        end
      end

      class UltimateAbility < LoyaltyAbility
        def loyalty_change = -6
        def description = "You get an emblem with \"Whenever you cast an Elf spell, it gains haste until end of turn and you draw two cards.\""

        def resolve!
          game.add_emblem(Emblem.new(game: game, owner: controller))
        end
      end

      def loyalty_abilities = [PlusOneAbility, ZeroAbility, UltimateAbility]
    end
  end
end
