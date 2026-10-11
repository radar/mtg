module Magic
  module Cards
    ManifestDread = Sorcery("Manifest Dread") do
      cost generic: 1, green: 1
    end

    class ManifestDread < Sorcery
      # "Manifest dread."
      def resolve!
        Magic::Choice::ManifestDread.perform(actor: self)
      end
    end
  end
end
