m = Map("system", translate("WiFi Password"),
	translate("Changes the WIFI password or SSID, you can change each other independently.  Password length must be greater than 8"))

s = m:section(TypedSection, "_dummy", "")
s.addremove = false
s.anonymous = true

sd = s:option(Value, "ssid", translate("WiFi name (SSID)"))

placehold = s:option(Flag,"enable",translate("Change wifi Name and Password together"))

pw1 = s:option(Value, "pw1", translate("Password"))
pw1.password = true

pw2 = s:option(Value, "pw2", translate("Password Confirmation"))
pw2.password = true

function s.cfgsections()
	return { "_pass" }
end

function m.on_commit(map)
	local SSID = sd:formvalue("_pass")
	local v1 = pw1:formvalue("_pass")
	local v2 = pw2:formvalue("_pass")
	local sok = 'not'
	local pok = 'not'

	if SSID then
		luci.sys.exec("uci set wireless.@wifi-iface[0].ssid='" .. SSID .. "' && uci commit")
		sok = 'ok'
	else
		m.message = translate("SSID NOT changed!! SSID cannot be blank!")
	end

	if v1 == v2 and #v1 >7 then
		luci.sys.exec("uci set wireless.@wifi-iface[0].key='" .. v1 .. "' && uci commit")
		pok = 'ok'
	else
		m.message = translate("Password not changed!\n Password LENGTH must be greater than 8!\n OR your can just leave it blank, changing the SSID only.")
		if #v1 == 0 then
			pok = 'ok'
		end
	end

	if sok == 'ok'and pok == 'ok' then
		m.message = translate("Password or SSID successfully changed!")
		luci.sys.exec("/etc/init.d/network restart")
	end

end

return m
