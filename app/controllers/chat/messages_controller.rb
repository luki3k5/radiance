class Chat::MessagesController < ApplicationController
  def create
    # mystery is solved when you manage to get the following expression to return anything
    # (given that there is already a channel record in the db)
    # because at the moment it returns []. I suspect a string match problem in sqlite??????
    # Channel.where(:token => Channel.first.token) 
    mystery_solved = false
    puts "params are: #{params[:channel]}"
    if mystery_solved
      channel = Channel.find_by_token(params[:channel])

      raise "channel not found: #{params[:channel]}" unless channel
      msg = Message.new(profile:current_user, body: params[:body], channel: channel)

      if msg.save
        message_html = render(:partial => 'chat/message', :locals => { :message => msg })
        Juggernaut.publish(channel.token, message_html.first)
      end
    else

      msg = Message.new(profile:current_user, body: params[:body])

      if msg.save
        message_html = render(:partial => 'chat/message', :locals => { :message => msg })
        Juggernaut.publish(params[:channel], message_html.first)
      end
    end
  
    head :ok if msg.save
  end

  def index
    # not needed
    render :json => current_user.messages.to_json
  end
end
