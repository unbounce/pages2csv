require 'awesome_print'
require 'csv'
require 'multi_json'
require 'net/https'
require 'uri'

class ApiInterface
  attr_reader :api_key

  def initialize(api_key)
    @api_key    = api_key
  end


  def get(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth(@api_key, '')

    response = http.request(request)
    response.body
  end

end


class UnbouncePage

  def initialize(api_interface, page_id)
    @api_interface = api_interface
    @page_id       = page_id
    @data          = {}
  end


  def fetch
    json = @api_interface.get(api_uri)
    @data = MultiJson.decode(json)
    self
  end


  def stats
    return if @data.empty?

    curr = tests['current']
    @stats = { id: @page_id, name: name, url: url, visitors: curr['visitors'], conversions: curr['conversions'] }
  end

  private

    def api_uri
      URI.parse("https://api.unbounce.com/pages/#{@page_id}")
    end


    def method_missing(meth, *args, &block)
      data = @data[meth.to_s]
      data ? data : super
    end

end


# UnbouncePages
#
# Calls the API and extracts page data for a collection of pages.
#
class UnbouncePages
  attr_reader :api_key, :pages
  attr_accessor :company_id

  def initialize(api_interface, company_id, offset=0, limit=50)
    @api_interface  = api_interface
    @company_id     = company_id
    @offset         = offset
    @limit          = limit
  end


  def fetch
    json = @api_interface.get(api_uri)
    data = MultiJson.decode(json)
    build_pages(data)
    self
  end


  def as_csv
    CSV.open(file_name, "wb") { |csv| csv << @pages.first.stats.keys }
    CSV.open(file_name, "ab") { |csv| @pages.each { |elem| csv << elem.stats.values.to_a } }
  end


  def file_name
    "#{DateTime.now.strftime("%F")}-#{company_id}-page-export.csv"
  end

  private

    def api_uri
      URI.parse("https://api.unbounce.com/sub_accounts/#{@company_id}/pages?offset=#{@offset}&limit=#{@limit}")
    end


    def build_pages(data)
      @pages = data['pages'].map { |page_data| UnbouncePage.new(@api_interface, page_data['id']).fetch }
    end

end

# ------------------------------ Main ------------------------------

# Uses an Unbounce API key and a Subdomain ID to extract data about all the
# pages in that subdomain.
#
# Example:
#
#   ruby page2csv.rb 07d92b143345a48b491ee5a6147b848f 47742
#
if __FILE__ == $0
  ai = ApiInterface.new(ARGV[0])
  pe = UnbouncePages.new(ai, ARGV[1], 0, 1000)
  pe.fetch.as_csv

  puts "Wrote #{pe.file_name}/"
end
