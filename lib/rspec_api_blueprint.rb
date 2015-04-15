require "rspec_api_blueprint/version"
require "rspec_api_blueprint/string_extensions"
require "rspec_api_blueprint/nested_hash"
require "rspec_api_blueprint/documentation_builder"

RSpec.configure do |config|
  config.before(:suite) do
    $api_blueprint = NestedHash.new
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
    @action = example.description
    example.run
  end

  config.after(:each, type: :request, api_docs: true) do
    break if response.nil? || response.status == 401 || response.status == 403 || response.status == 301

    doc = if @level_3
            $api_blueprint[@level_1][@level_2][@level_3][@action] = String.new
          elsif @level_2
            $api_blueprint[@level_1][@level_2][@action] = String.new
          elsif @level_1
            $api_blueprint[@level_1][@action] = String.new
          end

    # Request
    request_body = request.body.read
    if request_body.present?
      doc << "+ Request (#{request.content_type})\n\n"
      # Request Body
      if request_body.present? && 'application/json' == request.content_type.to_s
        doc << "#{JSON.pretty_generate(JSON.parse(request_body))}\n\n".indent(8)
      end
    end

    # Response
    doc << "+ Response #{response.status} (#{response.content_type})\n\n"
    # Response Headers
    doc << "+ Headers\n\n".indent(4)
    response.headers.each do |k, v|
      next if /Content-Type/i === k
      doc << "#{k}: #{v.gsub(/\n+/, ' ')}\n\n".indent(12)
    end
    # Response Body
    doc << "+ Body\n\n".indent(4)
    if response.body.present?
      if /application\/json/ === response.content_type.to_s
        doc << "#{JSON.pretty_generate(JSON.parse(response.body))}\n\n".indent(12)
      else
        doc << "response.body".indent(12)
      end
    end
  end

  config.after(:suite) do
    DocumentationBuilder.build $api_blueprint
  end
end
