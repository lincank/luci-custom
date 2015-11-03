--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2011 Jo-Philipp Wich <xm@subsignal.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

]]--

module("luci.controller.admin.sysupgrade", package.seeall)

function index()
	entry({"admin", "sysupgrade"}, call("action_upgrade"), _("系统更新"), 80).index = true
end

function action_upgrade()
	local reboot = luci.http.formvalue("reboot")
	luci.template.render("admin_sysupgrade/index", {reboot=reboot})
	if reboot then
		luci.sys.exec("/etc/init.d/upgrade.lala")
	end
end


