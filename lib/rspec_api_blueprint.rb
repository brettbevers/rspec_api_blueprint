require "rspec_api_blueprint/version"
require "rspec_api_blueprint/nested_document"
require "rspec_api_blueprint/documentation_builder"
require "rspec_api_blueprint/action"

RSpec.configure do |config|
  config.before(:suite) do
    $api_blueprint = NestedDocument.new
  end

  config.around(:each, type: :request, api_docs: true) do |example|
    example_group = example.metadata[:example_group]
    example_groups = []
    while example_group
      example_groups << example_group
      example_group = example_group[:example_group]
    end

    @level_3 = example_groups[-3][:description_args].first if example_groups[-3]
    @level_2 = example_groups[-2][:description_args].first if example_groups[-2]
    @level_1 = example_groups[-1][:description_args].first
    example_description = "+ #{example.description}\n\n"
    $api_blueprint.path_append @level_1, @level_2, DocumentationBuilder::EXAMPLES_KEY, example_description

    example.run
  end

  config.after(:each, type: :request, api_docs: true) do
    break if response.nil? || response.status == 401 || response.status == 403 || response.status == 301
    blueprint = Action.new(request, response).to_blueprint
    $api_blueprint.path_append @level_1, @level_2, @level_3, blueprint
  end

  config.after(:suite) do
    DocumentationBuilder.build $api_blueprint
  end
end
