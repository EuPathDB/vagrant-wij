This is a guideline for setting up Jenkins for WDK workspace development.

**The jobs are purely 'proof of concept' demonstrations at this point, not intended to represent actual implementations.**

For HTML in job descriptions, enable Safe HTML (optional)

    Manage Jenkins -> Configure Global Security -> Markup Formatter: Safe HTML

## Plugins:

- [Build Blocker Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Build+Blocker+Plugin)
- [Groovy](https://wiki.jenkins-ci.org/display/JENKINS/Groovy+plugin)
- [Job DSL](https://wiki.jenkins-ci.org/display/JENKINS/Job+DSL+Plugin)

These plugins can be installed through the Plugin Manager UI or more
quickly by running the following Groovy code in the [Script
Console](http://wij.vm:9171/script)

    import jenkins.model.*
    def instance = Jenkins.getInstance()
    def pm = instance.getPluginManager()
    def uc = instance.getUpdateCenter()
    def plugins = ['build-blocker-plugin', 'job-dsl', 'groovy']
    plugins.each {
      println("Checking " + it)
      if (!pm.getPlugin(it)) {
        println("Looking in UpdateCenter for " + it)
        def plugin = uc.getPlugin(it)
        if (plugin) {
          println("Installing " + it)
          plugin.deploy()
          needs_restart = true
        }
      }
    }
    instance.doSafeRestart()


## Job Generator

Create a seed job will be used to generate all other jobs using the
Job-DSL plugin.

Run the following Groovy code in the [Script
Console](http://wij.vm:9171/script)

    import jenkins.model.Jenkins;
    import hudson.model.FreeStyleProject;

    job = Jenkins.instance.createProject(FreeStyleProject, 'job-generator')
    job.customWorkspace = '/vagrant'
    job.displayName = 'job-generator'

    builder = new javaposse.jobdsl.plugin.ExecuteDslScripts()
    builder.targets = 'workspacesJobs.groovy'
    job.buildersList.add(builder)
    job.save()
    job.scheduleBuild(0)

## Job DSL

At the root of the Vagrant project on the Vagrant host is a
`workspacesJobs.groovy` file that defines Jenkins jobs used for
workspaces workflows. It is NFS shared on the guest VM at
`/vagrant/workspacesJobs.groovy` and executed when the `job-generator`
job runs.

For DSL information see
[Jenkins Job DSL API](https://jenkinsci.github.io/job-dsl-plugin/)



