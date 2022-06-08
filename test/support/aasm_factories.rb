module AASMFactories
  SCOPE = "Munificent".freeze

  def self.init(definition_proxy, definition, class_name: nil)
    class_name ||= definition.name

    trimmed_name = class_name
      .to_s
      .gsub(/^#{SCOPE.downcase}_/, "")
      .camelize

    klass = "#{SCOPE}::#{trimmed_name}".constantize

    klass.aasm.states.each do |state|
      definition_proxy.trait(state.name) do
        add_attribute(klass.aasm.attribute_name) { state.name }
      end
    end
  end
end
