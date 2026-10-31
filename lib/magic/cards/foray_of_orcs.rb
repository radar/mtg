module Magic
  module Cards
    ForayOfOrcs = Sorcery("Foray of Orcs") do
      cost generic: 3, red: 1
    end

    class ForayOfOrcs < Sorcery
      # "When you do, Foray of Orcs deals X damage to target creature an opponent controls, where X is the amassed
      # Army's power." X is read when the reflexive trigger resolves.
      class DamageChoice < Magic::Choice::Targeted
        def initialize(actor:, army:)
          @army = army
          super(actor: actor)
        end

        def choice_amount = 1

        def choices = game.opponents(controller).flat_map { _1.creatures.to_a }

        def resolve!(target:)
          @army.apply_continuous_effects!
          deal_damage(@army.power, to: target)
        end

        # The target is mandatory, so skipping still picks a legal target.
        def decline!
          target = choices.first
          resolve!(target: target) if target
        end
      end

      # "Amass Orcs 2. When you do, ..."
      def resolve!
        army = Magic::Amass.call(source: self, controller: controller, amount: 2, subtype: "Orc")
        if army
          choice = DamageChoice.new(actor: self, army: army)
          game.add_choice(choice) if choice.choices.any?
        end
        super
      end
    end
  end
end
