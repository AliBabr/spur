class Api::V1::HistoryController < ApplicationController
    def index
        if User.validate_token(request.headers['X-SPUR-USER-ID'],request.headers["Authentication-Token"])!=false
          user=User.find_by_id(request.headers['X-SPUR-USER-ID'])
          if user.present?
            history=user.histories
            histories=[]
            user.histories.each do |history|
              histories << {place_type: history.place_type, name: history.name, date: history.created_at.to_date}
            end
            render json: histories, :status => 200
          else
            render :json =>{ :message => "User not found!"}, :status => :not_found
          end
        else
          render :json =>{ :message => "Unauthorized!"}, :status => :Unauthorized
        end 
    end
end
