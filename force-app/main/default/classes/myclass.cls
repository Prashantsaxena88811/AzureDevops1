public with sharing class myclass {
	public myclass() {
		getAppVersion();
	}

	public String getAppVersion() {
		System.debug('chnages gddddddddddddddddddddddetApp11111111111111111111111111111111111VerddddddddsiongetAppVersiongetAppVersiongetAppVersion done');
		System.debug('for testing1');
		return '1.0.0';
	}
}
# Starter pipelinee
# Start with a minimal pipeline that you can customize to build and deploy your code.
# Add steps that build, run tests, deploy, and more:
# https://aka.ms/yaml

trigger:
  batch: "true"
  branches:
    include:
      - master
jobs:
- job: ProdDeploy
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/master'))
  steps:
    - task: UseNode@1
    - bash: 
        npm install sfdx-cli --global
      displayName: Install Salesforce CLI
    - bash: 
        sfdx force:auth:jwt:grant --clientid $(salesforceProdClientid) --jwtkeyfile ./server.key --username $(salesforceProdUsername) --instanceurl $(salesforceProdInstanceUrl) -a prod
      displayName: Authorize salesforce org
    - bash: 
        sfdx force:source:deploy -l RunLocalTests -p ./force-app -u prod -w 10
      displayName: Deploying Extra Metadata to the Org
    