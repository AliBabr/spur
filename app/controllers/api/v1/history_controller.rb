class Api::V1::HistoryController < ApplicationController
    def index
        if User.validate_token(request.headers["UUID"],request.headers["Authentication-Token"])!=false
          user=User.find_by_id(request.headers["UUID"])
          if user.present?
            history=user.histories
            render :json => {:message => "Success", :data => history.as_json(only: [:place_type, :google_place_id, :lat, :lng])}, :status => :ok
          else
            render :json =>{ :message => "User not found!"}, :status => :not_found
          end
        else
          render :json =>{ :message => "Unauthorized!"}, :status => :Unauthorized
        end 
    end
end
