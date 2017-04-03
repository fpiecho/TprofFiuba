class NotificationsController < ApplicationController
  before_action :set_notification, only: [:show, :edit, :update, :destroy]
  before_action :set_mobile_app, only: [:index, :new]

  layout "application_internal_styled"

  # GET /notifications
  # GET /notifications.json
  def index
    if(@mobile_app.user_id.equal? current_user.id)
      @notifications = Notification.all.where(mobile_app: @mobile_app)
    end
  end

  # GET /notifications/1
  # GET /notifications/1.json
  def show
  end

  # GET /notifications/new
  def new
    @notification = Notification.new
  end

  # GET /notifications/1/edit
  def edit
    @mobile_app = MobileApp.find(@notification.mobile_app_id)
  end

  # POST /notifications
  # POST /notifications.json
  def create
    @notification = Notification.new(notification_params)
    @notification.sent = false;
    @mobile_app = MobileApp.find(@notification.mobile_app_id)
    if(@mobile_app.user_id.equal? current_user.id)  
      respond_to do |format|
        if @notification.save
          format.html { redirect_to notifications_url + "/" + @notification.mobile_app_id.to_s, notice: 'Notificacion creada exitosamente.' }
          format.json { render :show, status: :created, location: @notification }
        else
          format.html { render :new }
          format.json { render json: @notification.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /notifications/1
  # PATCH/PUT /notifications/1.json
  def update
    @mobile_app = MobileApp.find(@notification.mobile_app_id)
    if(@mobile_app.user_id.equal? current_user.id)
      respond_to do |format|
        if @notification.update(notification_params)
          format.html { redirect_to notifications_url + "/" + @notification.mobile_app_id.to_s, notice: 'Notificacion actualizada exitosamente.' }
          format.json { render :show, status: :ok, location: @notification }
        else
          format.html { render :edit }
          format.json { render json: @notification.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /notifications/1
  # DELETE /notifications/1.json
  def destroy
    @mobile_app = MobileApp.find(@notification.mobile_app_id)
    if(@mobile_app.user_id.equal? current_user.id)
      @notification.destroy
      respond_to do |format|
        format.html { redirect_to notifications_url + "/" + @notification.mobile_app_id.to_s, notice: 'Notificacion destruida exitosamente.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_notification
      @notification = Notification.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def notification_params
      params.require(:notification).permit(:message, :title, :mobile_app_id, :action_date)
    end

    def set_mobile_app
      if (params[:id])
        @mobile_app = MobileApp.find(params[:id])
        if(!@mobile_app.user_id.equal? current_user.id)
          raise "error"
        end
      end
    end
end
