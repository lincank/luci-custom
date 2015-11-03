m = Map("system", translate("WiFi Password"),
	translate("Changes the WIFI password or SSID"))

s = m:section(TypedSection, "_dummy", "")
s.addremove = false
s.anonymous = true

sd = s:option(Value, "ssid", translate("ssid"))

pw1 = s:option(Value, "pw1", translate("Password"))
pw1.password = true

pw2 = s:option(Value, "pw2", translate("Confirmation"))
pw2.password = true

if apply then
    io.popen("/etc/init.d/network restart")
end

function s.cfgsections()
	return { "_pass" }
end

function m.on_commit(map)
	local SSID = sd:formvalue("_pass")
	local v1 = pw1:formvalue("_pass")
	local v2 = pw2:formvalue("_pass")

	if v1 and v2 and #v1 > 7 and #v2 > 7 then
		if v1 == v2 then
			if luci.sys.exec("uci set wireless.@wifi-iface[0].ssid='"  .. SSID .. "' && uci set wireless.@wifi-iface[0].key='" .. v1 .. "'&& uci commit && echo ok") == 'ok\n' then
				m.message = translate("Password or SSID successfully changed!")
			else
				m.message = translate(" password LENGTH must be greater than  8 !")
			end
		else
			m.message = translate("Given password confirmation did not match, password not changed!")
		end
	end
end

return m
