module Magic
  module Cards
    class OverlordOfTheBoilerbilges < Overlord
      card_name "Overlord of the Boilerbilges"
      cost generic: 4, red: 2
      impending 4, Costs::Mana.new(generic: 2, red: 2)
      power 5
      toughness 5

      class DamageChoice < Magic::Choice::Targeted
        def choices = game.any_target

        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:deal_damage, damage: 4, target: target)
        end
      end

      # "Whenever this permanent enters or attacks, it deals 4 damage to any target."
      enters_or_attacks do
        game.add_choice(OverlordOfTheBoilerbilges::DamageChoice.new(actor: actor))
      end
    end
  end
end
