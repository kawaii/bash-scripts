SSH_ENV=$HOME/.ssh/environment.$HOSTNAME

function start_agent {
     echo "Initialising new SSH agent..."
     /usr/bin/ssh-agent | sed 's/^echo/#echo/' > ${SSH_ENV}
     echo succeeded
     chmod 600 ${SSH_ENV}
     source ${SSH_ENV} > /dev/null
     /usr/bin/ssh-add;
}

if [ -f "${SSH_ENV}" ]; then
     source ${SSH_ENV} > /dev/null
     ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
         start_agent;
     }
else
     start_agent;
fi
