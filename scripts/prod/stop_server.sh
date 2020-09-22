kill $(ps ax | grep phx.server | sed '/grep/d' | awk '{print $1}')
