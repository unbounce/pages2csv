require 'forwardable'

class ApiInterface
  extend Forwardable

  def initialize(argv)
    @opts = Options.new(argv)
  end

  def_delegators :@opts, :apikey, :subaccount, :offset, :limit

  def get(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth(apikey, '')

    response = http.request(request)
    response.body
  end

end
