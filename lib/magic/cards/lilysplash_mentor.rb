module Magic
  module Cards
    LilysplashMentor = Creature("Lilysplash Mentor") do
      cost generic: 2, green: 1, blue: 1
      creature_type("Frog Druid")
      keywords :reach
      power 4
      toughness 4
    end

    class LilysplashMentor < Creature
      # {1}{G}{U}: Exile another target creature you control, then return it to the battlefield under its owner's
      # control with a +1/+1 counter on it. Activate only as a sorcery.
      class BlinkAbility < Magic::ActivatedAbility
        costs "{1}{G}{U}"
        activate_only_as_sorcery

        def target_choices = battlefield.controlled_by(controller).creatures - [source]

        def resolve!(target:)
          card = target.card
          exile_target(target)
          returned = card.resolve!(controller: card.owner) if card.zone&.exile?
          returned&.add_counter("+1/+1")
        end
      end

      def activated_abilities = [BlinkAbility]
    end
  end
end
