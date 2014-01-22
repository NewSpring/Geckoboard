require "sinatra"
require "sinatra/json"
require "ooyala-v2-api"
require "active_support/core_ext"

module WIDGET
  class OoyalaAPI < Sinatra::Base
    helpers Sinatra::JSON

    get '/asset/:embed_code' do
      ooyala = Ooyala::API.new(ENV['OOYALA_API_KEY'], ENV['OOYALA_SECRET_KEY'])
      current = Time.new
      start_date = request['start_date']
      end_date = request['end_date'] ||= current.strftime("%F")

      video = ooyala.get('/v2/analytics/reports/account/performance/videos/'+params[:embed_code]+'/'+start_date+'...'+end_date+'/')
      json :item => [{:value => "#{video["results"][0]["metrics"]["video"]["plays"]}", :text => "#{video["results"][0]["name"]}"}]
    end
  end
end

