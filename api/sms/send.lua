-- Author: Davis Zeng  <daviszeng@outlook.com>

function run()

  local need = {"handset", "text"}

  if tool:required_check(post, need) == false then
    ngx.exit(400)
  end

  need = {
    handset = post.handset,
    text = post.text
  }

  local beanstalkd = require 'vendor.resty.beanstalkd'
  -- new and connect
  local bean, err = beanstalkd:new()
  if not bean then
    logger:error("beanstalkd初始化失败，错误信息为：" .. err)
    output({}, config.errorcodes.fail, "队列服务繁忙，请稍后再试。")
  end

  local ok, err = bean:connect(config.beanstalkd.host, config.beanstalkd.port)
  if not ok then
    logger:error("beanstalkd连接失败，错误信息为：" .. err)
    output({}, config.errorcodes.fail, "队列服务繁忙，请稍后再试。")
  end

  -- use tube
  local ok, err = bean:use(config.queue.sms.common)
  if not ok then
    logger:error("指定队列：" .. config.queue.sms.common .. "设置失败，错误信息为：" .. err)
  end

  -- put job
  local id, err = bean:put(json_encode(need))
  if not id then
    logger:error("压进队列失败，队列名称为：" .. config.queue.sms.common .. "，错误信息为：" .. err)
  end

  -- put it into the connection pool of size 100,
  -- with 0 idle timeout

  -- bean:set_keepalive(0, 100)

  -- close and quit beanstalkd
  bean:close()
  output(id)
end
