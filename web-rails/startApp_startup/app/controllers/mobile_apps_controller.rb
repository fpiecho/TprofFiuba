class MobileAppsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_mobile_app, only: [:show, :edit, :update, :destroy]
  before_filter :require_permission, only: [:edit, :show]

  def require_permission
    if current_user.id != MobileApp.find(params[:id]).user_id
      redirect_to root_path
    end
  end

  # GET /mobile_apps
  # GET /mobile_apps.json
  def index
    @mobile_apps = current_user.mobile_apps
  end

  # GET /mobile_apps/1
  # GET /mobile_apps/1.json
  def show
    appPath = Rails.root.join('mobileApps').join(current_user.id.to_s).join(@mobile_app.title) 
    free_port = Selenium::WebDriver::PortProber.above(3000)
    Thread.new {
      system("cd #{appPath} && ionic serve -p #{free_port} --nobrowser --address localhost");
    }
    sleep 1.5
    @mobile_app.port = free_port.to_s
  end

  # GET /mobile_apps/new
  def new
    @mobile_app = MobileApp.new
  end

  # GET /mobile_apps/1/edit
  def edit
  end

  # POST /mobile_apps
  # POST /mobile_apps.json
  def create
    @mobile_app = MobileApp.new(mobile_app_params)

    respond_to do |format|
      @mobile_app.user_id = current_user.id
      if @mobile_app.save
        name = @mobile_app.title;
        appsPath = Rails.root.join('mobileApps');
        appType = @mobile_app.apptype.downcase;
        userPath = appsPath.join(current_user.id.to_s)
        FileUtils.mkdir_p(userPath) unless File.directory?(userPath)
        appPath = userPath.join(name);
        %x[cd #{userPath} && ionic start "#{name}" #{appType}]
        %x[cd #{appPath} && ionic platform add android]

        format.html { redirect_to @mobile_app, notice: 'Mobile app ' + name +' was successfully created.' }
        format.json { render :show, status: :created, location: @mobile_app }
      else
        format.html { render :new }
        format.json { render json: @mobile_app.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mobile_apps/1
  # PATCH/PUT /mobile_apps/1.json
  def update
    respond_to do |format|
      if(@mobile_app.user_id.equal? current_user.id)
        if @mobile_app.update(mobile_app_params)
          format.html { redirect_to @mobile_app, notice: 'Mobile app was successfully updated.' }
          format.json { render :show, status: :ok, location: @mobile_app }
        else
          format.html { render :edit }
          format.json { render json: @mobile_app.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /mobile_apps/1
  # DELETE /mobile_apps/1.json
  def destroy
    if(@mobile_app.user_id.equal? current_user.id)
      title = @mobile_app.title 
      @mobile_app.destroy
      appPath = Rails.root.join('mobileApps').join(current_user.id.to_s).join(title);
      FileUtils.rm_rf(appPath)
      respond_to do |format|
        format.html { redirect_to mobile_apps_url, notice: 'Mobile app was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mobile_app
      @mobile_app = MobileApp.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mobile_app_params
      params.require(:mobile_app).permit(:title, :description, :apptype)
    end
end
