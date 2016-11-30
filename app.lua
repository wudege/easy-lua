-- Author: Davis Zeng  <daviszeng@outlook.com>

config = require "config.main"
cjson = require("cjson")
json_encode = cjson.encode
json_decode = cjson.decode
loggingfile = require("logging.file")
logger = loggingfile(ngx.var.root .. "/runtime/logs/app.log.%s", "%Y-%m-%d")
tool = require("helper.tool")

function output(data, code, message)
	local data = data or {}
	local code = code or config.errorcodes.success
	local message = message or ""
	local response = {
			data = data,
			code = code,
			message = message
	}
	ngx.print(json_encode(response))
	ngx.exit(200)
end

app, get, post = {}, {}, {}

function app:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function app:load()
	if ngx.var.uri == nil or ngx.var.uri == "/" then
		ngx.exit(404)
	end
	local fun, e = loadfile(ngx.var.root .. ngx.var.uri .. ".lua")
	if e or not fun then
		ngx.exit(404)
	end
	fun()
	if not run then
		ngx.exit(404)
	end
end

function app:init()
	local request_data = ngx.req.get_uri_args()
	if request_data ~= nil then
		for key, value in pairs(request_data) do
			if type(value) == "table" then
				ngx.exit(400)
			end
			get[key] = value
		end
	end
	request_data = ngx.req.get_post_args()
	if request_data ~= nil then
		for key, value in pairs(request_data) do
			if type(value) == "table" then
				ngx.exit(400)
			end
			post[key] = value
		end
	end
end

function app:run()
	app:load()
	app:init()
	run()
end

instance = app:new()
instance:run()
