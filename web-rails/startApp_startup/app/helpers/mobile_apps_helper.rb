module MobileAppsHelper

	def self.create_app(name, userPath, appType)
		FileUtils.mkdir_p(userPath) unless File.directory?(userPath)
        appPath = userPath.join(name);
        modelName = get_model_name(appType);
        modelPath = Rails.root.join('modelos').join(modelName);
        FileUtils.cp_r modelPath, appPath
        replace_on_app_creation(appPath, name, modelName);

	end

	def self.replace_on_app_creation(appPath, appName, modelName)
		replace(appPath.join('package.json'), modelName) { |match| appName }
		replace(appPath.join('ionic.config.json'), modelName) { |match| appName }
		replace(appPath.join('config.xml'), modelName) { |match| appName }
		replace(appPath.join('plugins/android.json'), modelName) { |match| appName }
		replace(appPath.join('platforms/android/AndroidManifest.xml'), modelName) { |match| appName }
		replace(appPath.join('platforms/android/android.json'), modelName) { |match| appName }
		replace(appPath.join('platforms/android/res/values/strings.xml'), modelName) { |match| appName }
		replace(appPath.join('platforms/android/res/xml/config.xml'), modelName) { |match| appName }

		androidDirectory = appPath.join('platforms/android/src/com/ionicframework')
		oldDirectory = Dir.entries(androidDirectory).sort_by {|x| x.length}.last()
		number = /\d+/.match(oldDirectory)[0]
		FileUtils.mv androidDirectory.join(oldDirectory), androidDirectory.join(appName + number)

		replace(androidDirectory.join(appName + number).join('MainActivity.java'), modelName) { |match| appName }
	end

	def self.get_model_name(appType)
		if(appType == 'tabs')
			return 'moldet'
		else
			return 'moldes'
		end
	end

	def self.new_page(appPath, tabName, appType)
		system("cd \"#{appPath}\" && ionic g page \"#{tabName}\"");

		if (appType == 'Tabs')
			new_tab(appPath, tabName)
		else
			new_menu_page(appPath, tabName)
		end
	end

	def self.new_menu_page(appPath, tabName)
		#app.ts
		tabsTsPath = appPath.join('app').join('app.ts')
		tabNameForPage = tabName[0].upcase + tabName[1..tabName.length - 1]		
		replace(tabsTsPath, '@Component({') { |match| "import { " + tabNameForPage +"Page } from './pages/" + tabName +"/" + tabName + "';" + "\n" + "#{match}" }
		replace(tabsTsPath, '];') { |match| ",{ title: '" + tabName + "', component: " + tabNameForPage + "Page }" + "\n" + "#{match}" }

		#app.core.css
		importCore = '@import "../pages/' + tabName + '/' + tabName + '";'+ "\n"
		coreCssPath = appPath.join('app').join('theme').join('app.core.scss')
		
		File.open(coreCssPath, "a+") do |f|
  			f << importCore
		end

		#page.html 
		pagePath = appPath.join('app').join('pages').join(tabName).join(tabName + '.html')
		replace(pagePath, '<ion-navbar>') { |match| "#{match}" + '<button menuToggle>
      <ion-icon name="menu"></ion-icon>
    </button>' }

	end

	def self.new_tab(appPath, tabName)
		#app.core.css
		importCore = '@import "../pages/' + tabName + '/' + tabName + '";'+ "\n"
		coreCssPath = appPath.join('app').join('theme').join('app.core.scss')
		
		File.open(coreCssPath, "a+") do |f|
  			f << importCore
		end

		#tabs.html
		tabsPath = appPath.join('app').join('pages').join('tabs').join('tabs.html')
		tabLine = '<ion-tab [root]="tab' + tabName + '" tabTitle="' + tabName +'" tabIcon="' + tabName + '"></ion-tab>' + "\n"
		replace(tabsPath, /^<\/ion-tabs>/mi) { |match| tabLine + "#{match}"}

		#tabs.ts
		tabsTsPath = appPath.join('app').join('pages').join('tabs').join('tabs.ts') 
		tabNameForPage = tabName[0].upcase + tabName[1..tabName.length - 1]
		replace(tabsTsPath, 'constructor() {') { |match| "#{match}" + "\n" + "this.tab" + tabName + " = " + tabNameForPage + "Page;"}
		replace(tabsTsPath, 'export class TabsPage {') { |match| "#{match}" + "\n" + "private tab" + tabName + ": any;"}
		replace(tabsTsPath, '@Component({') { |match| "import {" + tabNameForPage +"Page} from '../" + tabName +"/" + tabName + "';" + "\n" + "#{match}" }
	end

	def self.replace(filepath, regexp, *args, &block)
		content = File.read(filepath).gsub(regexp, *args, &block)
		File.open(filepath, 'wb') { |file| file.write(content) }
	end

	def self.set_content(appPath, tabName, content)
		tabPath = appPath.join('app').join('pages').join(tabName).join(tabName + '.html')
		replace(tabPath, /<ion-content padding>\n(.*\n)*<\/ion-content>/) { |match| "<ion-content padding>" + "\n" + content + "\n" + "</ion-content>"}
	end


	def self.delete_page(appPath, tabName, appType)
		FileUtils.rm_rf(appPath.join('app').join('pages').join(tabName))

		if (appType == 'Tabs')
			delete_tab(appPath, tabName)
		else
			delete_menu_page(appPath, tabName)
		end
	end

	def self.delete_menu_page(appPath, tabName)
		#app.ts
		appTsPath = appPath.join('app').join('app.ts')
		tabNameForPage = tabName[0].upcase + tabName[1..tabName.length - 1]		
		replace(appTsPath, "import { " + tabNameForPage +"Page } from './pages/" + tabName +"/" + tabName + "';" + "\n" ) { |match| '' }
		replace(appTsPath, /,((?!,)[\S\s])*{ title: '#{tabName}', component: #{tabNameForPage}Page }/) { |match| '' }

		#app.core.css
		importCore = '@import "../pages/' + tabName + '/' + tabName + '";'+ "\n"
		coreCssPath = appPath.join('app').join('theme').join('app.core.scss')
		replace(coreCssPath, importCore) { |match|  }

	end

	def self.delete_tab(appPath, tabName)
		#app.core.css
		importCore = '@import "../pages/' + tabName + '/' + tabName + '";'+ "\n"
		coreCssPath = appPath.join('app').join('theme').join('app.core.scss')
		replace(coreCssPath, importCore) { |match|  }

		#tabs.html
		tabsPath = appPath.join('app').join('pages').join('tabs').join('tabs.html')
		tabLine = '<ion-tab [root]="tab' + tabName + '" tabTitle="' + tabName +'" tabIcon="' + tabName + '"></ion-tab>' + "\n"
		replace(tabsPath, tabLine) { |match| ''}

		#tabs.ts
		tabsTsPath = appPath.join('app').join('pages').join('tabs').join('tabs.ts') 
		tabNameForPage = tabName[0].upcase + tabName[1..tabName.length - 1]
		replace(tabsTsPath, "this.tab" + tabName + " = " + tabNameForPage + "Page;"+ "\n") { |match| ''  }
		replace(tabsTsPath, "private tab" + tabName + ": any;"+ "\n") { |match| ''}
		replace(tabsTsPath, "import {" + tabNameForPage +"Page} from '../" + tabName +"/" + tabName + "';" + "\n") { |match|  '' }
	end
end
