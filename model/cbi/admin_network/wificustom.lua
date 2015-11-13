so = luci.sys.exec("uci get wireless.@wifi-iface[0].ssid")
po = luci.sys.exec("uci get wireless.@wifi-iface[0].key")
m = Map("system", translate("current  WiFi name is:  " .. so .. "  <br /> current password is:  " .. po),
        translate("Changes the WIFI password or SSID, you can change each other independently.<br />Password length must be greater than 8"))

s = m:section(TypedSection, "_dummy", "")
s.addremove = false
s.anonymous = true

sd = s:option(Value, "ssid", translate("WiFi name (SSID)"))

s_button = s:option(Button,"_btn",translate("Change Name"))

pw1 = s:option(Value, "pw1", translate("Password"))
pw1.password = true

p_button = s:option(Button,"_btn_2",translate("Change  Password"))


function s.cfgsections()
	return { "_pass" }
end

function s_button.write()
	local SSID = sd:formvalue("_pass")
	if SSID and #SSID > 0 then
		luci.sys.exec("uci set wireless.@wifi-iface[0].ssid='" .. SSID .. "' && uci commit")
		m.message = translate("Success! SSID changed to: " .. SSID .. ". Click the save buttom to save the changes")
	else
		m.message = translate("SSID NOT changed!! SSID cannot be blank!")
	end
end

function p_button.write()
	local pd = pw1:formvalue("_pass")
	if pd and #pd > 7 then
		luci.sys.exec("uci set wireless.@wifi-iface[0].key='" .. pd .. "' && uci commit")
		m.message = translate("Success! password changed to: " .. pd .. ". Click the save buttom to save the changes")
	else
		m.message = translate("Password  NOT changed!! Password cannot be blank!  Password length must be greater than 8 ")
	end
end


function m.on_commit(map)
	luci.sys.exec("/etc/init.d/network restart")
end

return m
