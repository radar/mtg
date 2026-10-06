module Magic
  class ManaAbility < ActivatedAbility
    attr_reader :choice

    def self.choices(*choices)
      if choices == [:all]
        define_method(:choices) { %i[white blue black red green] }
      else
        define_method(:choices) { choices }
      end
    end

    # Abilities that always make the same mana (Selesnya Sanctuary: `mana_produced` => { green: 1, white: 1 }) have
    # nothing to choose, so they never declare `choices`. A single placeholder choice lets #resolve! pick it itself.
    def choices = [:fixed]

    # True for "add one mana of any type that a land you control could produce" (Reflecting Pool, Exotic Orchard). Such an
    # ability asks every land's mana abilities for their choices, so it must skip other abilities that do the same, or
    # they would ask each other forever (rule 106.7: ignore mana abilities that depend on themselves).
    def reflects_other_lands? = false

    def initialize(**args)
      super(**args)
    end

    def controller
      source.controller
    end

    def choose(color)
      @choice = color
    end

    def resolve!
      # An ability that fixes its mana by overriding `mana_produced` (a `{B}{G}` bounce land) has no
      # choice to make, so it doesn't need `choices`.
      if respond_to?(:choices)
        @choice ||= choices.first if choices.length == 1

        raise "Invalid choice made for mana ability. Choice: #{choice}, Choices: #{choices}" unless choices.include?(choice)
      end
      mana = mana_produced
      if mana_restriction
        source.controller.add_mana(mana, restriction: mana_restriction)
      else
        source.controller.add_mana(**mana)
      end

      game.battlefield.static_abilities.each do |ability|
        next unless ability.respond_to?(:additional_mana)

        ability.additional_mana(source, mana)
      end
    end

    def mana_produced
      { choice => 1 }
    end

    # A ManaRestriction ("spend this mana only to ...") for the mana this ability adds, or nil.
    def mana_restriction = nil
  end
end
