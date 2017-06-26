This is a guideline for setting up Jenkins for WDK workspace development.

## Plugins:

- [Build Blocker Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Build+Blocker+Plugin)
- [Groovy](https://wiki.jenkins-ci.org/display/JENKINS/Groovy+plugin)
- [Job DSL](https://wiki.jenkins-ci.org/display/JENKINS/Job+DSL+Plugin)

(see puppet/src/profiles/manifests/ebrc_jenkins.pp for a full list)

Plugins are managed via puppet and groovy scripts.  All required plugins should install 
automatically.  If additional plugins are needed, they can be installed manually, but please
let us know so that the puppet profile can be updated to include them.

## Job Generator

Jobs are created automatically via the groovy script found at
/usr/local/home/jenkins/irodsWorkspacesJobs.groovy.  This is linked into the
subversion checkout location defined in hiera. ( for this vm, the hiera data
can be found in puppet/environments//savm/hieradata/common.yaml )  
The value of :profiles::svn_files::checkout_location is set to /vagrant/scratch/svn_files.  So,
/usr/local/home/jenkins/irodsWorkspacesJobs.groovy ->
/vagrant/scratch/svn_files/Resources/JenkinsJobs/irodsWorkspacesJobs.groovy 

## Job DSL

The irodsWorkspacesJobs.groovy script is run at jenkins restart, and any uncreated
jobs will be created at that time.  If you need to edit/change these jobs, just restart
jenkins (via "systemctl restart jenkins@WS").  You may want to check /var/log/jenkins/WS.log 
to check for any errors.

For DSL information see
[Jenkins Job DSL API](https://jenkinsci.github.io/job-dsl-plugin/)



