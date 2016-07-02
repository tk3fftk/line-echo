# Mostly taken from http://qiita.com/masuidrive/items/1042d93740a7a72242a3

require 'sinatra/base'
require 'json'
require 'rest-client'

class App < Sinatra::Base

  def line_post(content_json)
    endpoint_uri = 'https://trialbot-api.line.me/v1/events'
    RestClient.proxy = ENV['FIXIE_URL'] if ENV['FIXIE_URL']
    RestClient.post(endpoint_uri, content_json, {
      'Content-Type' => 'application/json; charset=UTF-8',
      'X-Line-ChannelID' => ENV["LINE_CHANNEL_ID"],
      'X-Line-ChannelSecret' => ENV["LINE_CHANNEL_SECRET"],
      'X-Line-Trusted-User-With-ACL' => ENV["LINE_CHANNEL_MID"],
    })
  end

  to_id = ENV['LINE_TO_ID']

  post '/linebot/callback' do
    params = JSON.parse(request.body.read)

    params['result'].each do |msg|
      request_content = {
        to: [msg['content']['from']],
        toChannel: 1383378250, # Fixed  value
        eventType: "138311608800106203", # Fixed value
        content: msg['content']
      }
      content_json = request_content.to_json
      line_post(content_json)
    end

    "OK"
  end

  get '/linebot/message/:text' do
    content = {
      contentType: 1,
      toType: 1,
      "text": params[:text]
    }

    request_content = {
      to: [to_id],
      toChannel: 1383378250, # Fixed  value
      eventType: "138311608800106203", # Fixed value
      content: content
    }

    content_json = request_content.to_json
    line_post(content_json)
    "OK"
  end

end
