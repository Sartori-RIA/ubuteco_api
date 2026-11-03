# frozen_string_literal: true

module Ai
  class Embeddings
    class Voyage
      URL = 'https://api.voyageai.com/v1/embeddings'

      def self.embed(texts)
        response = post(texts)
        body = JSON.parse(response.body)
        Array(body.fetch('data'))
          .sort_by { |row| row.fetch('index') }
          .map { |row| row.fetch('embedding') }
      rescue JSON::ParserError, KeyError, SocketError, Timeout::Error, Errno::ECONNREFUSED => e
        raise ProviderError, e.message
      end

      def self.post(texts)
        uri = URI(URL)
        request = Net::HTTP::Post.new(uri)
        request['Authorization'] = "Bearer #{ENV.fetch('VOYAGE_API_KEY')}"
        request['Content-Type'] = 'application/json'
        request.body = { input: texts, model: Embeddings::MODEL }.to_json

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.open_timeout = 10
        http.read_timeout = 30
        response = http.request(request)
        return response if response.is_a?(Net::HTTPSuccess)

        raise ProviderError, "voyage #{response.code}"
      end
    end
  end
end
