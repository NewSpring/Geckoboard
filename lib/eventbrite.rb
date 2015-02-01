require 'sinatra'
require 'sinatra/json'
require 'eventbrite-client'

module WIDGET
  class EventbriteAPI < Sinatra::Base
  helpers Sinatra::JSON

    get '/:eid/:level' do
      eb_auth_tokens = {
        app_key: ENV['EB_APP_KEY'],
        user_key: ENV['EB_USER_KEY']
      }

      eb_client = EventbriteClient.new(eb_auth_tokens)
      response = eb_client.event_get({ id: params[:eid] })

      level = params[:level].to_i
      level = level-1
      ticket = response['event']['tickets'][level]

      # json :item => ticket
      json :item => "#{ticket['ticket']['quantity_sold']}", :min => { :value => 0 }, :max => { :value => "#{ticket['ticket']['quantity_available']}" }
    end
  end
end
