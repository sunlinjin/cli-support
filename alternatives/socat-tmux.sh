
#!/bin/bash
#
# on the client run:
#     ./socat-tmux.sh user@hostname
# on the server run:
#     socat file:`tty`,raw,echo=0 tcp-connect:localhost:6000
#
PORT=6000
SESSION=support
which socat >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo 'Cannot find socat'
  exit 1;
fi
which tmux >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo 'Cannot find tmux'
  exit 1;
fi
${1:?Usage $0 [user@hostname]}
ssh -R $PORT:localhost:$PORT -N $1 &
PID_SSH=$!
tmux new-session -d -s $SESSION
set -- $(stty size) # $1 = rows $2 = columns
CMD="stty rows $1; stty cols $2"
socat system:"$CMD & tmux attach -t $SESSION",pty,stderr,setsid,sigint,sane\
  tcp-listen:$PORT,bind=localhost,reuseaddr &
PID_SOCAT=$!
tmux attach -t $SESSION
tmux kill-session -t $SESSION >/dev/null 2>&1
kill $PID_SSH $PID_SOCAT
