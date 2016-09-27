require 'nokogiri'
require 'open-uri'
require "csv"
# begin
	@page=Nokogiri::HTML(open("https://www.tripadvisor.in/Hotel_Review-g297628-d2038751-Reviews-Ibis_Bengaluru_Techpark-Bengaluru_Bangalore_Karnataka",:read_timeout => 10000000000000000))
	
	#Hotel Info
	@hotel=@page.css("h1.heading_name").text.gsub!(/[^0-9A-Za-z' '']/, '')
	@city = @page.css("span.locality span:nth-child(1)").text
	@country = @page.css("span.country-name")[0].text
	@review=@page.css("span.sprite-rating_cl_gry img").attr('alt').value
	@review_count = @page.css("span.tabs_pers_counts")[0].text.gsub(/[()]/,'').to_i
	@total_pages = @page.css("a.pageNum").last.text.to_i

	CSV.open("hotel.csv", "wb") do |csv|
		csv << ["Review Url", "Review Title" , "Review Text", "Review Response", "Review Date", "Customer Review Count","Customer Name", "Customer Location"]
		(0..(@total_pages-1)).each do |i|
			@review_page=Nokogiri::HTML(open("https://www.tripadvisor.in/Hotel_Review-g297628-d2038751-Reviews-or"+(i*10).to_s+"-Ibis_Bengaluru_Techpark-Bengaluru_Bangalore_Karnataka",:read_timeout => 10000000000000000))
			
			(0..9).each do |j|
				@review_exist = @review_page.css('div.quote a')[j]
				if @review_exist.nil?
					break
				else
					@review_url = @review_exist.attr('href')
					@review_title = @review_page.css('span.noQuotes')[j].text
					# if !@review_t.nil?
					# 	@review_title = @review_t.text
					# else
					# 	@review_title = "Title Not Fount"
					# end
					@review_text = @review_page.css('div.entry p.partial_entry')[j].text.gsub!(/[^0-9A-Za-z' ''@,.]/, '')
					# if !@r_text.nil?
						# @review_text = @r_text.text.gsub!(/[^0-9A-Za-z' ''@,.]/, '')
					# else
					# 	@review_text = "No review text"
					# end
					@response = @review_page.css('div.mgrRspnInline p.partial_entry')[j]
					@review_date = @review_page.css('span.ratingDate')[j].attr('title')
					# if !@r_date.nil?
					# 	@review_data = @r_date.attr('title')
					# else
					# 	@review_date = "Review date not found"
					# end
					@total_cust_review = @review_page.css('div.reviewerBadge span.badgeText')[j].text
					# if !@cust_review.nil?
					# 	@total_cust_review = @cust_review.text
					# else
					# 	@total_cust_review = "Customer review count not fount"
					# end
					if i==0
						@mem_info = @review_page.css('div.username')[j+1].text.gsub!(/[^0-9A-Za-z' '',.@]/, '')
					else
						@mem_info = @review_page.css('div.username')[j].text.gsub!(/[^0-9A-Za-z' '',.@]/, '')
					end
					# if !@mem_name.nil?
					# 	@mam_info =@mem_name.text.gsub!(/[^0-9A-Za-z' '',.@]/, '')
					# else
					# 	@mem_info = "No Name"
					# end
					@location = @review_page.css('div.location')[j].text.gsub!(/[^0-9A-Za-z' '',.@]/, '')
					# if !@loc.nil?
					# 	@location = @loc.text.gsub!(/[^0-9A-Za-z' '',.@]/, '')
					# else
					# 	@location = "Location not found"
					# end
					if !@response.nil?
						@review_data = Nokogiri::HTML(open("https://www.tripadvisor.in"+@review_url))
						@review_res = @review_data.css("div.displayText")[0]
						if !@rev_resp.nil?
							@review_response = @rev_resp.text.gsub!(/[^0-9A-Za-z' '',.@]/, '') 
						else
							@review_response = "No response"
						end
					else
						@review_response = "No response"
					end
				end

				
				csv << ["https://www.tripadvisor.in"+@review_url,@review_title,@review_text,@review_response,@review_date ,@total_cust_review,@mem_info,@location]
			end
		end
	end
# rescue
# 	p "Internet issue"
# end

