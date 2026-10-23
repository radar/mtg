module Magic
  module Cards
    ShilgengarSireOfFamine = Creature("Shilgengar, Sire of Famine") do
      cost generic: 3, black: 2
      legendary_creature_type "Elder Demon"
      power 6
      toughness 6
      keywords :flying
    end

    class ShilgengarSireOfFamine < Creature
      # "Sacrifice another creature: Create a Blood token. If you sacrificed an Angel this way, create a number of Blood
      # tokens equal to its toughness instead."
      class SacrificeAbility < Magic::ActivatedAbility
        costs "Sacrifice another creature"

        def resolve!(sacrificed:)
          creature = sacrificed.first
          amount = creature.type?("Angel") ? creature.toughness : 1
          create_token(token: Tokens::Blood, amount: amount)
        end
      end

      # "Sacrifice six Blood tokens": paid with `pay_sacrifice([blood] * 6)`.
      class SacrificeSixBlood < Costs::Sacrifice
        def choices = permanent.controller.permanents.select { _1.name == "Blood" }

        def can_pay?(_player = nil) = choices.size >= 6

        def unpayable_reason
          "#{permanent.controller.name} controls fewer than six Blood tokens" unless can_pay?
        end

        def pay(payment:)
          payment = Array(payment)
          raise ArgumentError, "Sacrifice exactly six Blood tokens" unless payment.size == 6 && payment.uniq.size == 6
          raise ArgumentError, "Only Blood tokens you control can be sacrificed" unless payment.all? { choices.include?(_1) }

          payment.each(&:sacrifice!)
        end
      end

      # "{W/B}{W/B}{W/B}, Sacrifice six Blood tokens: Return each creature card from your graveyard to the battlefield with
      # a finality counter on it. Those creatures are Vampires in addition to their other types."
      class ReanimateAbility < Magic::ActivatedAbility
        def costs
          [*Costs::Parser.parse(source: source, costs: "{W/B}{W/B}{W/B}"), SacrificeSixBlood.new(source, nil)]
        end

        def resolve!
          controller.graveyard.cards.select(&:creature?).each do |card|
            reanimate(card, controller: controller, counters: { "finality" => 1 })
            permanent = controller.permanents.find { _1.card == card }
            permanent&.add_types(T::Creatures["Vampire"], until_eot: false)
          end
          game.tick!
        end
      end

      def activated_abilities = [SacrificeAbility, ReanimateAbility]
    end
  end
end
