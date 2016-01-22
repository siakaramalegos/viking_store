class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update, :destroy]
  before_action :set_user, only: [:update, :destroy]

  def new
    @user = User.new
    @user.addresses.build
    @user.addresses.build
    addresses = @user.addresses
    addresses.each { |address| address.build_city }
  end

  def create
    @user = User.new(user_params)

    if @user.save
      set_default_addresses
      sign_in(@user)
      redirect_to products_index_url, notice: "You successfully registered!"
    else
      flash.now[:alert] = "There was a problem submitting your form.  See below for errors."
      render :new
    end
  end

  def edit
    @user = User.where(id: current_user.id).includes(:addresses => :city).first
    addresses = @user.addresses
    # addresses.build
    # addresses.last.build_city
  end

  def update
    if @user.update(user_params)
      set_default_addresses
      redirect_to products_index_url, notice: "Your user information was successfully updated!"
    else
      flash.now[:alert] = "There was a problem submitting your form.  See below for errors."
      render :edit
    end
  end

  def destroy
    if @user.destroy
      sign_out
      redirect_to products_index_url, notice: "Account successfully deleted."
    else
      redirect_to products_index_url, alert: "Account could not be deleted."
    end
  end

  private

  def set_default_addresses
    if addresses = user_params[:addresses_attributes]
      if billing_index = params[:default_billing_index]
        address = addresses[billing_index]
        if address[:id]
          @user.billing_id = address[:id]
        else
          @user.billing_id = @user.addresses.where(street_address: address[:street_address]).first.id
        end
      end

      if shipping_index = params[:default_shipping_index]
        address = addresses[shipping_index]
        if address[:id]
          @user.shipping_id = address[:id]
        else
          @user.shipping_id = @user.addresses.where(street_address: address[:street_address]).first.id
        end
      end

      @user.save
    end
  end

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :phone_number, { :addresses_attributes => [:id, :street_address, :secondary_address, :state_id, :zip_code, :_destroy, city_attributes: [:name]] })
  end
end
