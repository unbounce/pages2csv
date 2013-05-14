require 'awesome_print'
require 'csv'
require 'multi_json'
require 'net/https'
require 'optparse'
require 'uri'

class Options
  attr_accessor :apikey, :subaccount, :offset, :limit

  def initialize(options)
    @opts = OptionParser.new do |parser|
      parser.on('-k <apikey>',      '--apikey',     'Your Unbounce API key.')         { |opt| @apikey       = opt }
      parser.on('-s <subaccount>',  '--subaccount', 'Your subaccount ID.')            { |opt| @subaccount   = opt }
      parser.on('-o <offset>',      '--offset',     'First record index.')            { |opt| @offset       = opt }
      parser.on('-l <limit>',       '--limit',      'Number of records to retrieve.') { |opt| @limit        = opt }
    end

    @opts.parse!(options)
    set_defaults
  end

  private

    def set_defaults
      @offset = 0   if @offset.nil?
      @limit  = 50  if @limit.nil?
    end
end


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


# UnbouncePage
#
# Calls the API and extracts detailed data about a specific page.
#
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
    "#{DateTime.now.strftime("%F")}-#{@api_interface.subaccount}-page-export.csv"
  end

  private

    def api_uri
      URI.parse("https://api.unbounce.com/sub_accounts/#{@api_interface.subaccount}/pages?offset=#{@api_interface.offset}&limit=#{@api_interface.limit}")
    end

    def build_pages(data)
      @pages = data['pages'].map { |page_data| UnbouncePage.new(@api_interface, page_data['id']).fetch }
    end

end

# ------------------------------ Main ------------------------------

# Uses an Unbounce API key and a subaccount ID to extract data about all the
# pages in that subaccount.
#
# Parameters
#
#   Required:
#     --apikey  Your Unbounce API key.
#     --subaccount   The numeric ID of the subaccount that has your pages.
#
#   Optional:
#     --offset      The first page to start from. Defaults to 0
#     --limit       The number of pages to retrieve. Defaults to 50
#
# Examples:
#
#   ruby pages2csv.rb --apikey 07b491ee5a6147d92b143345a48b848f --subaccount 47742 --offset 50 --limit 100
#   ruby pages2csv.rb -k 07b491ee5a6147d92b143345a48b848f -s 47742
#
if __FILE__ == $0
  ai = ApiInterface.new(ARGV)
  up = UnbouncePages.new(ai)
  up.fetch.as_csv

  puts "Wrote #{up.file_name}."
end
