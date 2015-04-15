require "rspec_api_blueprint/string_extensions"

class Action

  def initialize(request, response)
    @request = request
    @response = response
  end

  attr_reader :request, :response

  def to_blueprint
    request_part + response_part
  end

  private

  def request_part
    doc = String.new
    return doc unless request
    doc << "+ Request (#{request.content_type})\n\n"
    doc << "+ Headers\n\n".indent(4)
    request.headers.each do |k, v|
      next if /Content-Type/i === k
      doc << "#{k}: #{v.gsub(/\n+/, ' ')}\n\n".indent(12)
    end
    doc << "+ Body\n\n".indent(4)
    request_body = request.body.read
    if request_body.present?
      if 'application/json' == request.content_type.to_s
        doc << "#{JSON.pretty_generate(JSON.parse(request_body))}\n\n".indent(8)
      else
        doc << request_body.indent(12)
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
      next if /Content-Type/i === k
      doc << "#{k}: #{v.gsub(/\n+/, ' ')}\n\n".indent(12)
    end
    doc << "+ Body\n\n".indent(4)
    if response.body.present?
      if /application\/json/ === response.content_type.to_s
        doc << "#{JSON.pretty_generate(JSON.parse(response.body))}\n\n".indent(12)
      else
        doc << response.body.indent(12)
      end
    end
    doc
  end
end