require 'awesome_print'
require 'csv'
require 'multi_json'
require 'net/https'
require 'optparse'
require 'uri'

class ConfigurationParser
  attr_accessor :apikey, :subdomain, :offset, :limit

  def initialize(options)
    @opts = OptionParser.new do |parser|
      parser.on('-k <apikey>',    '--apikey',     'Your Unbounce API key.')         { |opt| @apikey     = opt }
      parser.on('-s <subdomain>', '--subdomain',  'Your Subdomain ID.')             { |opt| @subdomain  = opt }
      parser.on('-o <offset>',    '--offset',     'First record index.')            { |opt| @offset     = opt }
      parser.on('-l <limit>',     '--limit',      'Number of records to retrieve.') { |opt| @limit      = opt }
    end

    @opts.parse!(options)

    @offset = 0   if @offset.nil?
    @limit  = 50  if @limit.nil?
  end
end


class ApiInterface
  extend Forwardable

  def initialize(argv)
    @config = ConfigurationParser.new(argv)
  end

  def_delegators :@config, :apikey, :subdomain, :offset, :limit

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

  def initialize(api_interface)
    @api_interface  = api_interface
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
    file_name
  end

  def file_name
    "#{DateTime.now.strftime("%F")}-#{@api_interface.subdomain}-page-export.csv"
  end

  private

    def api_uri
      URI.parse("https://api.unbounce.com/sub_accounts/#{@api_interface.subdomain}/pages?offset=#{@api_interface.offset}&limit=#{@api_interface.limit}")
    end

    def build_pages(data)
      @pages = data['pages'].map { |page_data| UnbouncePage.new(@api_interface, page_data['id']).fetch }
    end

end

# ------------------------------ Main ------------------------------

# Uses an Unbounce API key and a Subdomain ID to extract data about all the
# pages in that subdomain.
#
# Parameters
#
#   Required:
#     --apikey  Your Unbounce API key.
#     --subdomain   The numeric ID of the subdomain that has your pages.
#
#   Optional:
#     --offset      The first page to start from. Defaults to 0
#     --limit       The number of pages to retrieve. Defaults to 50
#
# Example:
#
#   ruby pages2csv.rb --apikey 07b491ee5a6147d92b143345a48b848f --subdomain 47742 --offset 50 --limit 100
#
if __FILE__ == $0
  ai = ApiInterface.new(ARGV)
  up = UnbouncePages.new(ai)
  up.fetch.as_csv

  puts "Wrote #{up.file_name}/"
end
