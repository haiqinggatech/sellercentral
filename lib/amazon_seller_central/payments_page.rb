module AmazonSellerCentral
  class PaymentsPage < Page
    attr_accessor :page
    PAYMENT_FEED_V1 = "_GET_FLAT_FILE_PAYMENT_SETTLEMENT_DATA__"
    PAYMENT_FEED_V2 = "_GET_V2_SETTLEMENT_REPORT_DATA__"


    def has_next?
      @has_next ||= @page.search('a').map(&:text).grep(/Next/).any?
    end

    def next_page
      @next_page ||= begin
                       raise NoNextPageAvailableError unless has_next?
                       @page = @agent.follow_link_with(:text => 'Next')
                       PaymentsPage.new(:page => page, :agent => @agent)
                     end
    end

    def self.available_report_ids
      id_array = []
      mech = AmazonSellerCentral.mechanizer
      mech.login_to_seller_central
      mech.follow_link_with(:text => "Payments")
      payments_page = mech.follow_link_with(:text => "All Statements")
      @page = PaymentsPage.new(:page => payments_page, :agent => mech)
      id_array << @page.page.links_with(:text => "Download Flat File").map{|link| link.href.match(/(#{PAYMENT_FEED_V1}|#{PAYMENT_FEED_V2})(\d+)\.txt/)[2]}
      while(@page.has_next?)
        @page = @page.next_page
        id_array << @page.page.links_with(:text => "Download Flat File").map{|link| link.href.match(/(#{PAYMENT_FEED_V1}|#{PAYMENT_FEED_V2})(\d+)\.txt/)[2]}
      end
      id_array.flatten
    end
  end
end
