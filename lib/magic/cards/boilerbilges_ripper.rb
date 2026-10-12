module Magic
  module Cards
    BoilerbilgesRipper = Creature("Boilerbilges Ripper") do
      cost generic: 4, red: 1
      creature_type "Human Assassin"
      power 4
      toughness 4
    end

    class BoilerbilgesRipper < Creature
      # The reflexive trigger: "When you do, this creature deals 2 damage to any target."
      class DamageChoice < Magic::Choice::Targeted
        def prompt = "Deal 2 damage to any target."

        def choices = game.any_target

        def choice_amount = 1

        def resolve!(target:)
          deal_damage(2, to: target)
        end
      end

      # "When this creature enters, you may sacrifice another creature or enchantment."
      class SacrificeChoice < Magic::Choice::SacrificePermanent
        def prompt = "Sacrifice another creature or enchantment?"

        def candidates
          chooser.permanents.select { (_1.type?("Creature") || _1.type?("Enchantment")) && _1 != actor }
        end

        def resolve!(sacrifice: nil)
          super
          game.add_choice(DamageChoice.new(actor: actor))
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          choice = SacrificeChoice.new(actor: actor)
          game.add_choice(choice) if choice.candidates.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
