module Magic
  module Cards
    ChthonianNightmare = Enchantment("Chthonian Nightmare") do
      cost generic: 1, black: 1
    end

    class ChthonianNightmare < Enchantment
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          gain_energy 3
        end
      end

      # "Pay X {E}, Sacrifice a creature, Return this enchantment to its owner's hand: Return target creature card
      # with mana value X from your graveyard to the battlefield. Activate only as a sorcery."
      class ReanimateAbility < ActivatedAbility
        costs "Pay X {E}, Sacrifice a creature, Return {this} to its owner's hand"
        activate_only_as_sorcery

        def single_target? = true

        def target_choices = controller.graveyard.cards.select(&:creature?)

        def resolve!(target:, x:)
          return unless target.zone == controller.graveyard && target.mana_value == x

          Permanent.put_onto_battlefield(game: game, card: target, from_zone: target.zone, controller: controller)
        end
      end

      def etb_triggers = [EntersTrigger]

      def activated_abilities = [ReanimateAbility]
    end
  end
end
