require "rspec_api_blueprint/string_extensions"

class Action

  HEADER_FIELD_BLACKLIST = [
      /content.type/i,
      /^rack\./,
      /^action_dispatch\./,
      /warden/
  ]

  def initialize(request, response, description, additional_headers)
    @request = request
    @response = response
    @description = description
    @additional_headers = additional_headers.is_a?(Hash) ? additional_headers : Hash.new
  end

  attr_reader :request, :response, :description, :additional_headers

  def to_blueprint
    request_part + response_part
  end

  private

  def request_part
    doc = String.new
    return doc unless request
    doc << "+ Request #{description} (#{request.content_type})\n\n"
    doc << "+ Headers\n\n".indent(4)
    request_headers.each do |k, v|
      doc << "#{k}: #{v.gsub(/\n+/, ' ')}\n\n".indent(12)
    end
    doc << "+ Body\n\n".indent(4)
    request_body = request.body.read
    if request_body.present?
      if 'application/json' == request.content_type.to_s
        doc << "#{JSON.pretty_generate(JSON.parse(request_body))}\n\n".indent(12)
      else
        doc << request_body.indent(12) + "\n\n"
      end
    end
    doc
  end

  def response_part
    doc = String.new
    return doc unless response
    doc << "+ Response #{response.status} (#{response.content_type})\n\n"
    doc << "+ Headers\n\n".indent(4)
    response.headers.each do |k, v|
      next unless include_header?(k,v)
      doc << "#{k}: #{v.gsub(/\n+/, ' ')}\n\n".indent(12)
    end
    doc << "+ Body\n\n".indent(4)
    if response.body.present?
      if 'application/json' == response.content_type.to_s
        doc << "#{JSON.pretty_generate(JSON.parse(response.body))}\n\n".indent(12)
      else
        doc << response.body.indent(12) + "\n\n"
      end
    end
    doc
  end

  def include_header?(field, value)
    field_blacklisted = HEADER_FIELD_BLACKLIST.inject(false) { |a,b| a or b === field }
    !field_blacklisted && value.is_a?(String) && value.present?
  end

  def request_headers
    request.headers.select{ |k,v| include_header?(k,v) }.
        merge(additional_headers).
        merge(BLUEPRINT_EXAMPLE: description)
  end
end