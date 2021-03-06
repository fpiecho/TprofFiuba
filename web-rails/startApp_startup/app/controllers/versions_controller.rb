class VersionsController < ApplicationController
  before_action :set_version, only: [:show, :edit, :update, :destroy, :restore]
  before_action :set_mobile_app, only: [:index, :new]

  layout "application_internal_styled"

  # GET /versions
  # GET /versions.json
  def index
    if(@mobile_app.user_id.equal? current_user.id)
      @versions = Version.all.where(mobile_app: @mobile_app)
    end
  end

  # GET /versions/1
  # GET /versions/1.json
  def show
  end

  # GET /versions/new
  def new
    @version = Version.new
  end

  # GET /versions/1/edit
  def edit
    @mobile_app = MobileApp.find(@version.mobile_app_id)
  end

  # POST /versions
  # POST /versions.json
  def create
    @version = Version.new(version_params)
    @mobile_app = MobileApp.find(@version.mobile_app_id)
    if(@mobile_app.user_id.equal? current_user.id)
      respond_to do |format|
        if @version.save
          backupPath = Rails.root.join('versions').join(current_user.id.to_s).join(@version.mobile_app.title).join(@version.description) 
          FileUtils.mkdir_p(backupPath) unless File.directory?(backupPath)
          appPath = Rails.root.join('mobileApps').join(current_user.id.to_s).join(@version.mobile_app.title).join('*')
          FileUtils.cp_r Dir[appPath] , backupPath

          format.html { redirect_to versions_url + "/" + @version.mobile_app_id.to_s, notice: 'Version creada exitosamente.' }
          format.json { render :show, status: :created, location: @version }
        else
          format.html { render :new }
          format.json { render json: @version.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /versions/1
  # PATCH/PUT /versions/1.json
  def update
    @mobile_app = MobileApp.find(@version.mobile_app_id)
    if(@mobile_app.user_id.equal? current_user.id)
      @oldVersion = Version.find(@version.id)
      oldDescription = @oldVersion.description
      respond_to do |format|
        if @version.update(version_params)
          oldBackupPath = Rails.root.join('versions').join(current_user.id.to_s).join(@version.mobile_app.title).join(oldDescription)
          newBackupPath = Rails.root.join('versions').join(current_user.id.to_s).join(@version.mobile_app.title).join(@version.description) 
          File.rename oldBackupPath, newBackupPath
          format.html { redirect_to versions_url + "/" + @version.mobile_app_id.to_s, notice: 'Version actualizada exitosamente.' }
          format.json { render :show, status: :ok, location: @version }
        else
          format.html { render :edit }
          format.json { render json: @version.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /versions/1
  # DELETE /versions/1.json
  def destroy
    @mobile_app = MobileApp.find(@version.mobile_app_id)
    if(@mobile_app.user_id.equal? current_user.id)
      mobile_app_id = @version.mobile_app_id.to_s
      versionPath = Rails.root.join('versions').join(current_user.id.to_s).join(@version.mobile_app.title).join(@version.description) 
      FileUtils.rm_rf(versionPath)
      @version.destroy
      respond_to do |format|
        format.html { redirect_to versions_url + "/" + @version.mobile_app_id.to_s, notice: 'Version eliminada exitosamente.' }
        format.json { head :no_content }
      end
    end
  end

  def restore
    if(@version.mobile_app.user_id.equal? current_user.id)
      appPath = Rails.root.join('mobileApps').join(current_user.id.to_s).join(@version.mobile_app.title)
      versionPath = Rails.root.join('versions').join(current_user.id.to_s).join(@version.mobile_app.title).join(@version.description)
      if(File.directory?(versionPath))
        FileUtils.rm_rf(appPath)
        FileUtils.copy_entry versionPath, appPath
        respond_to do |format|
          format.html { redirect_to @version.mobile_app, notice: 'Version ' + @version.description + ' restaurada exitosamente.' }
          format.json { render :show, status: :created, location: @version.mobile_app }
        end
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_version
      @version = Version.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def version_params
      params.require(:version).permit(:description, :mobile_app_id)
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
