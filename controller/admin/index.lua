--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

module("luci.controller.admin.index", package.seeall)

function index()
	local root = node()
	if not root.target then
		root.target = alias("admin")
		root.index = true
	end

	local page   = node("admin")
	page.target  = firstchild()
	page.title   = _("Administration")
	page.order   = 10
	page.sysauth = "root"
	page.sysauth_authenticator = "htmlauth"
	page.ucidata = true
	page.index = true

	-- Empty services menu to be populated by addons
	entry({"admin", "services"}, firstchild(), _("Services"), 40).index = true

	entry({"admin", "logout"}, call("action_logout"), _("Logout"), 90)
	entry({"admin", "one_click"}, call("action_oneclick"), _("一键检测"), 85)
	entry({"admin", "migrate_server"}, call("action_migrate_server"), _("切换服务器"), 87)
end


function action_migrate_server()

	function mac()
  	return luci.sys.exec("ifconfig eth0.1 | grep HWaddr | awk '{print $5}'")
	end

	function reset_vpn_info(five_params_table)
		-- ip, port, net, mode, token = ...
		local t = five_params_table
		if type(t) == 'table' then
		  luci.sys.exec("uci set shadowvpn.@shadowvpn[0].server='" .. t[1] .. "'")
		  luci.sys.exec("uci set shadowvpn.@shadowvpn[0].port='" .. t[2] .. "'")
		  luci.sys.exec("uci set shadowvpn.@shadowvpn[0].net='" .. t[3] .. "'")
		  luci.sys.exec("uci set shadowvpn.@shadowvpn[0].user_token='" .. t[5] .. "'")
		  luci.sys.exec("uci set shadowvpn.@shadowvpn[0].route_mode_save='" .. t[4] .. "'")
		  luci.sys.exec("uci commit") 
		  luci.sys.exec("/etc/init.d/shadowvpn restart ") 
			return 'yes'
		end
		return 'no'
	end

	function digest_aes()
  	return luci.sys.exec("mpw turn")                           -- generate digest
	end

	function adjust_return_info(info_from_server)
		  local origin_string = luci.sys.exec("mpw turn  " .. info_from_server) -- TODO dec the digest, waiting gengCheng
			local r_t = {}
			local j = 1
			for i in string.gmatch(s,'[^,]+') do
				r_t[j] = i
				j = j + 1
			end
			if j == 5 then
				return r_t
			end
			return 'something wrong'
	end

	function json_2_table(json_string)
		local mm = require('luci.json')
		local j_s = json_string
		local raw_table = mm.decode(j_s)
		return raw_table
	end

	function clean_respond_content(raw_return_info)
		local count = 0
		local t = {}
		for i in string.gmatch(r,'[^%c]+') do
			count= count + 1
			t[count] = i
		end
		if count > 1 then
			return t[2]
		end
		return raw_return_info
	end

	local update_list = luci.http.formvalue("step_one")
	local submit_fm = luci.http.formvalue("step_two")
	local server_url = 'http://service.penewave.com/migrate_server'
	local httpc = require('luci.httpclient')
	local list = {}


	if update_list and #update_list > 0 then
		_, _, list_origin = httpc.request_raw(server_url, { body = { digest = digest_aes(), macaddr = mac() } })
		list = json_2_table(list_origin)
		if type(list) == 'table' then
	    return luci.template.render('migrate_server/index', { display_form = 'yes', server_list = list })
		end
    return luci.template.render('migrate_server/index', { display_form = 'no', is_worked = 'no' })
  end

	if submit_fm and #submit_fm >0 then
	  local chosen_one = luci.http.formvalue("chosen_one")
		_, _, raw_return_info = httpc.request_raw(server_url, { body = { digest = digest_aes(), macaddr = mac(), server_id = chosen_one } })

		return_info = clean_respond_content(raw_return_info)
		status = reset_vpn_info(adjust_return_info(return_info)) 
	  return luci.template.render('migrate_server/index', { is_worked = status, server = list[chosen_one] })
  end

	luci.template.render("migrate_server/index", { display_js = 'yes' })
end

function action_oneclick()
	local preform = luci.http.formvalue("perform")
	if preform then
  	luci.sys.exec("/etc/init.d/jc.shell")
  	m = io.popen("cat /root/report")
  	cable = m:read() or "something wrong,try again"
  	baidu = m:read() or " something wrong, try again"
  	google = m:read() or "NO"
		m:close()
  end
	luci.template.render("one_click/index", {cable=cable, baidu=baidu, google=google})
end


function action_logout()
	local dsp = require "luci.dispatcher"
	local sauth = require "luci.sauth"
	if dsp.context.authsession then
		sauth.kill(dsp.context.authsession)
		dsp.context.urltoken.stok = nil
	end

	luci.http.header("Set-Cookie", "sysauth=; path=" .. dsp.build_url())
	luci.http.redirect(luci.dispatcher.build_url())
end
