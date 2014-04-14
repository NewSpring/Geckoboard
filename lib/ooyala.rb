require "sinatra"
require "sinatra/json"
require "ooyala-v2-api"
require "active_support/core_ext"
require "chronic_duration"

module WIDGET
  class OoyalaAPI < Sinatra::Base
    helpers Sinatra::JSON
    ooyala = Ooyala::API.new(ENV['OOYALA_API_KEY'], ENV['OOYALA_SECRET_KEY'])

    get '/asset/:embed_code' do
      current = Time.new
      start_date = request['start_date']
      end_date = request['end_date'] ||= current.strftime("%F")

      video = ooyala.get('/v2/analytics/reports/account/performance/videos/'+params[:embed_code]+'/'+start_date+'...'+end_date+'/')
      json :item => [{:value => "#{video["results"][0]["metrics"]["video"]["plays"]}", :text => "#{video["results"][0]["name"]}"}]
    end

    get '/asset/playthrough/:embed_code' do
      current = Time.new
      start_date = request['start_date']
      end_date = request['end_date'] ||= current.strftime("%F")

      video = ooyala.get('/v2/analytics/reports/account/performance/videos/'+params[:embed_code]+'/'+start_date+'...'+end_date+'/')
      json :item => [{:value => "#{video["results"][0]["metrics"]["video"]["playthrough_25"]}", :label => "25%", :colour => "282828"},
                     {:value => "#{video["results"][0]["metrics"]["video"]["playthrough_50"]}", :label => "50%", :colour => "3C6E26"},
                     {:value => "#{video["results"][0]["metrics"]["video"]["playthrough_75"]}", :label=> "75%", :colour => "518933" },
                     {:value => "#{video["results"][0]["metrics"]["video"]["playthrough_100"]}", :label => "100%", :colour => "6BAC43"}]
    end

    get '/asset/time/:embed_code' do
      current = Time.new
      start_date = request['start_date']
      end_date = request['end_date'] ||= current.strftime("%F")

      video = ooyala.get('/v2/analytics/reports/account/performance/videos/'+params[:embed_code]+'/'+start_date+'...'+end_date+'/')

      time_in_sec = video["results"][0]["metrics"]["video"]["time_watched"]*0.001
      readable_time = ChronicDuration.output(time_in_sec, :format => :long)

      json :item => [{:text => "#{readable_time}", :type => 0}]
    end
  end
end

