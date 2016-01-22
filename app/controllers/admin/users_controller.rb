class Admin::UsersController < AdminController
  layout 'admin'
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :select_addresses, only: [:edit, :update]

  def index
    @users = User.includes(:default_billing_address => [:city, :state])
    @counts = Order.group(:user_id).count
    # @last_checkouts = Order.select('user_id, MAX(checkout_date)').group(:user_id).where('checkout_date IS NOT NULL')
  end

  def show
    @orders = @user.orders
  end

  def edit
  end

  def new
    @user = User.new
    @addresses = nil
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to admin_user_url(@user), notice: "User successfully created."
    else
      render :new
    end
  end

  def update
    if @user.update(user_params)
      redirect_to admin_user_url(@user), notice: "User successfully created."
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      redirect_to admin_users_url, notice: "User successfully deleted."
    else
      redirect_to admin_users_url, alert: "User could not be deleted."
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def select_addresses
    @addresses = @user.addresses
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone_number, :billing_id, :shipping_id)
  end
end
