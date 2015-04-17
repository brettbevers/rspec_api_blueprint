require "rspec_api_blueprint/example"
require "rspec_api_blueprint/action"
require "rspec_api_blueprint/documentation_builder"

module ApiBlueprint

  @@api_blueprint = NestedDocument.new

  def self.add(example, request, response)
    return if response.nil? || response.status == 401 || response.status == 403 || response.status == 301
    example = Example.new(example)
    blueprint = Action.new(request, response, example.description, example.headers).to_blueprint
    @@api_blueprint.path_append(*example.levels, blueprint)
  end

  def self.build
    DocumentationBuilder.build @@api_blueprint
  end

end