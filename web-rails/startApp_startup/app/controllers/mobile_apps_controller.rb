class MobileAppsController < ApplicationController
  helper_method :get_pages
  before_action :authenticate_user!
  before_action :set_mobile_app, only: [:show, :edit, :update, :destroy, :build, :new_page, :set_content, :delete_page, :get_pages, :page_exists]
  before_filter :require_permission, only: [:edit, :show]

  layout "application_internal_styled"

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
    start_app = params[:s]
    appPath = Rails.root.join('mobileApps').join(current_user.id.to_s).join(@mobile_app.title) 
    if(start_app != 'f')      
      free_port = Selenium::WebDriver::PortProber.above(3000)
      Thread.new {
        system("cd \"#{appPath}\"  && ionic serve -p #{free_port} --nobrowser --address localhost");
      }
      MobileAppsHelper.show()
      @mobile_app.port = free_port.to_s
      @mobile_app.save
    else
      #coreCssPath = appPath.join('app').join('theme').join('app.core.scss')
      #File.open(coreCssPath, "a+") do |f|
      #  f << " "
      #end
    end
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
      @mobile_app.title = @mobile_app.title.gsub(/\s+/, "");
      if @mobile_app.save
        name = @mobile_app.title;
        appType = @mobile_app.apptype.downcase;
        userPath = Rails.root.join('mobileApps').join(current_user.id.to_s)
        MobileAppsHelper.create_app(name, userPath, appType)

        format.html { redirect_to @mobile_app, notice: 'La aplicacion ' + name +' fue creada exitosamente.' }
        format.json { render :show, status: :created, location: @mobile_app }
      else
        format.html { render :new }
        format.json { render json: @mobile_app.errors, status: :unprocessable_entity }
      end
    end
  end

  def menu
    # Por ahora redirige a las pantallas, pero en el futuro crearia un menu que seria como el "tablero" de la app, 
    #y desde ahi voy a las diferentes opciones
    if (params[:id])
      session[:mobile_app_current_id] = params[:id]  
      redirect_to mobile_app_screens_path
    else
      redirect_to mobile_apps_path, alert: 'Debes seleccionar una aplicación.'
    end
  end

  # PATCH/PUT /mobile_apps/1
  # PATCH/PUT /mobile_apps/1.json
  def update
    respond_to do |format|
      if(@mobile_app.user_id.equal? current_user.id)
        if @mobile_app.update(mobile_app_params)
          format.html { redirect_to @mobile_app, notice: 'La aplicación fue actualizada exitosamente.' }
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
        format.html { redirect_to mobile_apps_url, notice: 'La aplicación fue eliminada exitosamente.' }
        format.json { head :no_content }
      end
    end
  end


  # GET /mobile_apps/build/1
  def build
    if(@mobile_app.user_id.equal? current_user.id)
      appPath = Rails.root.join('mobileApps').join(current_user.id.to_s).join(@mobile_app.title) 
      keyPath = Rails.root.join('release-key.keystore')
      apkPath = appPath.join('platforms/android/build/outputs/apk/android-release-unsigned.apk');
        system("cd \"#{appPath}\" && cordova build --release android");
        system("cd \"#{appPath}\" && jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore #{keyPath} -storepass 123123 -keypass 123123 #{apkPath} appready");
      send_file apkPath, :x_sendfile=>true
    end
  end


  #POST /mobile_apps/pages/:id/:name
  def new_page
    if(@mobile_app.user_id.equal? current_user.id)
      name = params[:name]
      type = params[:type]
      value = params[:value]
      
      appPath = Rails.root.join('mobileApps').join(current_user.id.to_s).join(@mobile_app.title) 
      tabPath = appPath.join('src').join('pages').join(name)
      if (File.directory?(tabPath))
        respond_to do |format|
          format.html { redirect_to mobile_apps_show_url(s: 'f'), notice: 'La pagina ya fue creada.' }
          format.json { render :show, status: :created, location: @mobile_app }
        end
      else
        MobileAppsHelper.new_page(@mobile_app, appPath, name, @mobile_app.apptype, type, value)
        respond_to do |format|
          format.html { redirect_to mobile_apps_show_url(s: 'f'), notice: 'Pagina ' + name +' creada exitosamente.' }
          format.json { render :show, status: :created, location: @mobile_app }
        end
      end
    end
  end

  #DELETE /mobile_apps/pages/:id/:name
  def delete_page
    if(@mobile_app.user_id.equal? current_user.id)
      name = params[:name]
      appPath = Rails.root.join('mobileApps').join(current_user.id.to_s).join(@mobile_app.title) 
      tabName = MobileAppsHelper.transform_name(name)
      tabPath = appPath.join('src').join('pages').join(tabName)
      if (File.directory?(tabPath))
        MobileAppsHelper.delete_page(appPath, name, @mobile_app.apptype)
        respond_to do |format|
          format.html { redirect_to mobile_apps_show_url(s: 'f'), notice: 'Pagina eliminada.' }
          format.json { render :show, status: :created, location: @mobile_app }
        end
      else
        respond_to do |format|
          format.html { redirect_to mobile_apps_show_url(s: 'f'), notice: 'La pagina ' + name +' no existe' }
          format.json { render :show, status: :created, location: @mobile_app }
        end
        
      end
    end
  end


  #POST /mobile_apps/content/:id/:name
  def set_content
    if(@mobile_app.user_id.equal? current_user.id)
      name = params[:name]
      content = params[:content]
      appPath = Rails.root.join('mobileApps').join(current_user.id.to_s).join(@mobile_app.title) 
      tabPath = appPath.join('src').join('pages').join(name).join(name + '.html')
      if (File.exist?(tabPath))
        MobileAppsHelper.set_content(appPath, name, content)
        respond_to do |format|
          format.html { redirect_to mobile_apps_show_url(s: 'f'), notice: 'Tab ' + name +' editado exitosamente.' }
          format.json { render :show, status: :created, location: @mobile_app }
        end
        
      else
        respond_to do |format|
          format.html { redirect_to mobile_apps_show_url(s: 'f'), notice: 'El Tab no existe.' }
          format.json { render :show, status: :created, location: @mobile_app }
        end        
      end
    end
  end

  def get_pages
    appPath = Rails.root.join('mobileApps').join(current_user.id.to_s).join(@mobile_app.title) 
    appType = @mobile_app.apptype.downcase;
    return MobileAppsHelper.get_pages(appPath, appType);
  end

  def page_exists
    name = params[:name]
    appPath = Rails.root.join('mobileApps').join(current_user.id.to_s).join(@mobile_app.title) 
    render :text => MobileAppsHelper.page_exists(appPath, name)
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

