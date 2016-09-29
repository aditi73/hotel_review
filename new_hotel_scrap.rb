
require 'nokogiri'
require 'open-uri'
require "csv"
require 'date'

begin
	@review_page=Nokogiri::HTML(open("https://www.expedia.co.in/Bengaluru-Hotels-Vivanta-By-Taj-M-G-Road.h526338-p1.Hotel-Reviews?rm1=a2&hwrqCacheKey=ea325fe6-3373-44cc-a861-1151fad5f524HWRQ1475048493611&"))
	#find total number of pages
	@page = @review_page.css('span.pagination-label').text
	i=-1
	@total_reviews=""
	while(@page[i]!='f')
		@total_reviews+=@page[i]
		i=i-1
	end
	@total_reviews=@total_reviews.gsub(/[' ']/,'').reverse.to_i
	@page_count = @total_reviews % 10
	if @page_count == 0
		@total_page = @total_reviews/10
	else
		@total_page = @total_reviews/10 + 1
	end
	@k = 9
	CSV.open("newhotel.csv", "wb") do |csv|
		csv << ["Review Title" , "Review Text","Review Date","Review Rating"]
		csv << []
		(0..(@total_page-1)).each do |i|
			if i == @total_page -1
				@k = @page_count - 1
			end
			#review details
			@review_page = Nokogiri::HTML(open("https://www.expedia.co.in/Bengaluru-Hotels-Vivanta-By-Taj-M-G-Road.h526338-p"+(i+1).to_s+".Hotel-Reviews?rm1=a2&hwrqCacheKey=ea325fe6-3373-44cc-a861-1151fad5f524HWRQ1475048493611&"))
			@review_page.css('div.details').each_with_index do |j,ind|
				@rating_score_only = j.css('span.rating-score-only')
				if @rating_score_only.empty? 
					@rev_title = j.css('h3')
					if !@rev_title.nil?
						@review_title = @rev_title.text
					else
						@review_title = "Title Not Available"
					end
					# puts @review_title
					@rev_date = j.css('span.date-posted')
					if !@rev_date.nil? and !@rev_date.text.empty?
						@r_date = @rev_date.text.gsub(" ",'')
						@review_date = Date.parse(@r_date[7..18]).strftime("%d/%m/%Y")
					else 
						@review_date = "Date Not Available"
					end
					# puts @review_date				

					@rev_text = j.css('div.review-text')
					if !@rev_text.nil?
						@review_text = @rev_text.text.gsub(";", ",")
					else
						@review_text = "Text Not Available"
					end
					# puts @review_text

								
					@review_rate = @review_page.css('span.rating span')[ind].text.to_i
					csv << [@review_title,@review_text,@review_date,@review_rate]
				end
			end
			
			
		end
	end
rescue
	puts "Internet Issue"
end

	
