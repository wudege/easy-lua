-- Author: Davis Zeng  <daviszeng@outlook.com>

local main = {}


-- beanstalkd mainure
main.beanstalkd = {
  host = "127.0.0.1",
  port = 11300
}

-- beanstalkd tube mainure
main.queue = {
  sms = {
    common = "sms_queue" -- 短信队列
  }
}

main.errorcodes = {
  success = 1, -- 成功
  fail = 0, -- 失败
}



return main
