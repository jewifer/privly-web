class ZeroBinsController < ApplicationController
  
  # Don't worry about CSRF
  skip_before_filter :verify_authenticity_token, :only => [:create, :show]
  
  # Load the resource only if the requestor has the random access token
  load_and_authorize_resource
  
  # JSON only endpoint for 
  def show
    @zero_bin.burn_after_date = Time.now + 1.day
    @zero_bin.save
    if @zero_bin.burn_after_date < Time.now
      raise ActiveRecord::RecordNotFound
    end
    
    zero_bin = @zero_bin.as_json(:only => [:ct, :iv, :salt])
    render :json => zero_bin, :callback => params[:callback]
  end
  
  # Store the ciphertext, initialization vector, and salt, then return
  # the URL in order to access the content
  def create
    
    @zero_bin.ct = params[:ct]
    @zero_bin.iv = params[:iv]
    @zero_bin.salt = params[:salt]
    #@zero_bin.random_token = params[:random_token]
    @zero_bin.burn_after_date = Time.now + 1.day
    
    if @zero_bin.save
      
      # Set the URL for the extensions to inject into pages
      response.headers["X-Privly-url"] = show_zero_bins_url @zero_bin, 
        {:random_token => @zero_bin.random_token, :burntAfter => @zero_bin.burn_after_date.to_i}
        
      render :json => @zero_bin, :status => :created, :location => @zero_bin
    else
      render :json => @zero_bin.errors, :status => :unprocessable_entity 
    end
  end

end
