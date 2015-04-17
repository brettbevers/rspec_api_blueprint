require "rspec_api_blueprint/version"
require "rspec_api_blueprint/api_blueprint"
require "rspec_api_blueprint/example"

RSpec.configure do |config|

  config.around(:each, type: :request, api_docs: true) do |example|
    @example = Example.new(example)
    example.run
  end

  config.after(:each, type: :request, api_docs: true) do
    ApiBlueprint.add(@example, request, response)
  end

  config.after(:suite) do
    ApiBlueprint.build
  end

end
