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
