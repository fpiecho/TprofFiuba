require 'rufus/scheduler'

scheduler = Rufus::Scheduler.new

scheduler.every '15s' do
	
	@notifications = Notification.all.where(sent: false)
	@notifications.each do |notification|
		if(notification.action_date < DateTime.now)
			url = URI.parse("https://api.ionic.io/push/notifications")
			https = Net::HTTP.new(url.host,url.port)
			https.use_ssl = true
			app_token = get_app_token(notification.mobile_app)
			request = Net::HTTP::Post.new(url.path, {'Content-Type' => 'application/json', "Authorization" => "Bearer " + app_token})

			request.body = "{\"send_to_all\":true,\"profile\":\"dev\",\"notification\":{  \"title\":\"" + notification.title + "\", \"message\":\"" + notification.message + "\"}}"
			res = https.request(request)
			puts res.body 
			notification.sent = true;
			notification.save;
		end
	end
end

def self.get_app_token(mobile_app)
	if(mobile_app.token.present?)
		puts "existe"
		return mobile_app.token;
	else
		puts "no existe"
		csrf_token = get_csrf_token();
		sessionid = post_login(csrf_token);
		appPath = Rails.root.join('mobileApps').join(mobile_app.user_id.to_s).join(mobile_app.title) 
		app_id = MobileAppsHelper.get_app_id(appPath)
		app_token = get_token(app_id, sessionid, csrf_token)
		mobile_app.token = app_token
		mobile_app.save
		return app_token;
	end
end


def self.get_csrf_token()
	url = URI.parse("https://apps.ionic.io/login")
	https = Net::HTTP.new(url.host,url.port)
	https.use_ssl = true
	request = Net::HTTP::Get.new(url.path, {'Content-Type' => 'application/x-www-form-urlencoded'})
	res = https.request(request)
    csrf_token = get_cookie(res, 'ion_cloud_csrf')
    return csrf_token
end

def self.get_cookie(res, cookie_name)
	all_cookies = res.get_fields('set-cookie')
	all_cookies.each { | cookie |
    	if(cookie.split('; ')[0].match(/^#{cookie_name}=/))
    		return cookie.split('; ')[0][cookie_name.length + 1..-1]
        end
    }
    return "";
end

def self.post_login(csrf_token)
	url = URI.parse("https://apps.ionic.io/login")
	https = Net::HTTP.new(url.host,url.port)
	https.use_ssl = true

	request = Net::HTTP::Post.new(url.path, {'Content-Type' => 'application/x-www-form-urlencoded', 
		'cookie' => 'ion_cloud_csrf='+csrf_token, 'x-csrftoken' =>  csrf_token});
	request.set_form_data({"username" => "fpiechotka@gmail.com", "password" => "123123", 
		"csrfmiddlewaretoken" => csrf_token, "next" => "", "s" => ""})
	res = https.request(request)
	sessionid = get_cookie(res, "sessionid")

	return sessionid
end

def self.get_token(app_id, sessionid, csrf_token)
	url = URI.parse("https://apps.ionic.io/auth/tokens/")
	https = Net::HTTP.new(url.host,url.port)
	https.use_ssl = true
	request = Net::HTTP::Get.new(url.path + "?app_id=" + app_id, {'cookie' => 'sessionid='+sessionid})
	res = https.request(request)
	token = string_between_markers(res.body, '"token":"')
end

def self.string_between_markers (text, marker)
	indice =text.index(marker) +9
	return text[indice..indice+142]
end