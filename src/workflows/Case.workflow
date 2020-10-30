<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Case_Email_Notification_For_L3_Agent</fullName>
        <description>Case Email Notification For L3 Agent</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>donotreply-portal@ecolab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Case_Assign_Notification_to_Owner</template>
    </alerts>
    <alerts>
        <fullName>Case_Comment_Notification_to_Customer</fullName>
        <description>Case Comment Notification to Customer</description>
        <protected>false</protected>
        <recipients>
            <field>Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>donotreply-portal@ecolab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Case_Comment_Notification_to_Customer</template>
    </alerts>
    <alerts>
        <fullName>Case_Callout_Failure_Notification_For_Technical_Team</fullName>
        <ccEmails>eCDSConnectIntegrationNotifications@ecolab.com</ccEmails>
        <description>Case Callout Failure Notification For Technical Team</description>
        <protected>false</protected>
        <recipients>
            <recipient>Technical_Team</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>donotreply-portal@ecolab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Case_Callout_Failure_Notification</template>
    </alerts>
    <alerts>
        <fullName>EC_SalesRepEmailAlert</fullName>
        <description>SalesRepEmailAlert</description>
        <protected>false</protected>
        <recipients>
            <field>EC_Sales_Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/EC_UserRoleApproval</template>
    </alerts>
    <alerts>
        <fullName>Case_Breach_Resolution_SLA_Email_Alert</fullName>
        <description>Case Breach Resolution SLA Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Case_Supervisor</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>donotreply-portal@ecolab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Ecolab_Connect_Breached_Resolution_SLA_Template</template>
    </alerts>
    <alerts>
        <fullName>Case_Breach_Response_SLA_Email_Alert</fullName>
        <description>Case Breach Response SLA Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>donotreply-portal@ecolab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Ecolab_Connect_Breached_Response_SLA_Template</template>
    </alerts>
    <alerts>
        <fullName>Case_Create_Notification_to_Customer</fullName>
        <description>Case Create Notification to Customer</description>
        <protected>false</protected>
        <recipients>
            <field>Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>donotreply-portal@ecolab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Case_Create_Notification_to_Customer</template>
    </alerts>
    <alerts>
        <fullName>Case_Owner_Change_Notification</fullName>
        <description>Case Owner Change Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>donotreply-portal@ecolab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Case_Assign_Notification_to_Owner</template>
    </alerts>
    <alerts>
        <fullName>Case_Resolved_Notification</fullName>
        <description>Case Resolved Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>donotreply-portal@ecolab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Case_Resolved_Notification</template>
    </alerts>
    <alerts>
        <fullName>Case_Resolved_Notification_Abandoned</fullName>
        <description>Case Resolved Notification - (Abandoned)</description>
        <protected>false</protected>
        <recipients>
            <field>Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>donotreply-portal@ecolab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Case_Resolved_Notifi_Due_to_Inactive</template>
    </alerts>
    <fieldUpdates>
        <fullName>Close_case_automatically_after_resolved</fullName>
        <field>Status</field>
        <literalValue>Closed</literalValue>
        <name>Close case automatically after resolved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_First_Response_Time</fullName>
        <field>First_Response_Time__c</field>
        <formula>Now()</formula>
        <name>FU First Response Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Resolution_SLA_Breached</fullName>
        <field>Is_Resolution_SLA_Breached__c</field>
        <literalValue>1</literalValue>
        <name>FU Resolution SLA Breached</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Resolved_Resolution_Time</fullName>
        <field>Resolved_Resolution_Time__c</field>
        <formula>NOW()</formula>
        <name>FU Resolved Resolution Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Response_SLA_Breached</fullName>
        <field>Is_Response_SLA_Breached__c</field>
        <literalValue>1</literalValue>
        <name>FU Response SLA Breached</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Status_to_Assigned</fullName>
        <field>Status</field>
        <literalValue>Assigned</literalValue>
        <name>Update Case Status to Assigned</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>EC_SalesRepRule</fullName>
        <actions>
            <name>EC_SalesRepEmailAlert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>OR((ISPICKVAL( Type , &quot;User Registration&quot;)),AND(ISPICKVAL( Type , &quot;Access Request&quot;),EC_Previous_Role__c = &quot;Basic&quot;,ISPICKVAL( EC_PortalAccessRole__c,&quot;Buyer&quot;)))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case Capture Resolution Time</fullName>
        <actions>
            <name>FU_Resolved_Resolution_Time</name>
            <type>FieldUpdate</type>
        </actions>        
        <active>true</active>
        <formula>AND(ISCHANGED(Status),TEXT(Status) == &apos;Resolved&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case Capture Response Time</fullName>
        <actions>
            <name>FU_First_Response_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Case_Status_to_Assigned</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(
				RecordType.Name==&#39;Support&#39;,
				ISBLANK( First_Response_Time__c),
                LEFT(OwnerId,3) = &#39;005&#39;,
                LEFT(PRIORVALUE(OwnerId),3) = &#39;00G&#39;				
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case Create Notification to Customer</fullName>
        <actions>
            <name>Case_Create_Notification_to_Customer</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>RecordType.Name == &apos;Support&apos; &amp;&amp;  BEGINS( OwnerId , &apos;00G&apos;)  &amp;&amp; Owner:Queue.DeveloperName !=  $Label.DCS_Agent &amp;&amp;  Hide_from_Customer__c == FALSE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case Owner Change Notification</fullName>
        <actions>
            <name>Case_Owner_Change_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(RecordType.Name == &apos;Support&apos;,
LEFT(OwnerId,3) == &apos;00G&apos;,
Owner:Queue.DeveloperName != $Label.DCS_Agent,
OR(ISNEW(), AND(ISCHANGED(OwnerId),Owner:Queue.Name != PRIORVALUE(Assigned_To_Queue__c)))
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case Resolved Notification and Close the case</fullName>
        <actions>
            <name>Case_Resolved_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>RecordType.Name == &apos;Support&apos;  &amp;&amp; Owner:Queue.DeveloperName != $Label.DCS_Agent &amp;&amp; TEXT(Status) == &apos;Resolved&apos; &amp;&amp; TEXT(Resolution_Category__c) != &apos;Case Abandoned&apos;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Close_case_automatically_after_resolved</name>
                <type>FieldUpdate</type>
            </actions>            
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers> 
    </rules>
    <rules>
        <fullName>Case Resolved Notification and Close the case %28Abandoned%29</fullName>
        <actions>
            <name>Case_Resolved_Notification_Abandoned</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>RecordType.Name == &apos;Support&apos; &amp;&amp; 
Owner:Queue.DeveloperName != $Label.DCS_Agent &amp;&amp; 
TEXT(Status) == &apos;Resolved&apos; &amp;&amp; 
TEXT(Resolution_Category__c) == &apos;Case Abandoned&apos; &amp;&amp;
Hide_from_Customer__c == false</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Close_case_automatically_after_resolved</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Resolution SLA Notification</fullName>
        <active>true</active>
        <formula>ISBLANK(Resolved_Resolution_Time__c) &amp;&amp; RecordType.Name == &apos;Support&apos;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Case_Breach_Resolution_SLA_Email_Alert</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>FU_Resolution_SLA_Breached</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.Resolution_SLA__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Response SLA Notification</fullName>
        <active>true</active>
        <formula>ISBLANK(First_Response_Time__c) &amp;&amp;  RecordType.Name == &apos;Support&apos; &amp;&amp; Owner:Queue.DeveloperName != $Label.DCS_Agent</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Case_Breach_Response_SLA_Email_Alert</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>FU_Response_SLA_Breached</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.Response_SLA__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Case Callout Failure Notification</fullName>
        <actions>
            <name>Case_Callout_Failure_Notification_For_Technical_Team</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Salesforce to ServiceNow, Case Callout Failure Notification</description>
        <formula>ISCHANGED( Integration_Status__c ) &amp;&amp; Integration_Status__c ==&apos;Submitted Failure&apos; &amp;&amp;  Assigned_To_Queue__c = &apos;DCS Agents&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case Comment Notification to Customer</fullName>
        <actions>
            <name>Case_Comment_Notification_to_Customer</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>RecordType.Name == &apos;Support&apos; &amp;&amp; 
Owner:Queue.DeveloperName != $Label.DCS_Agent &amp;&amp; 
ISCHANGED( Latest_Public_Case_Comment__c ) &amp;&amp;
 Hide_from_Customer__c == false</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case Email Notification For L3 Agent</fullName>
        <actions>
            <name>Case_Email_Notification_For_L3_Agent</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>For unresolved cases, sending email notification to L3 Agents</description>
        <formula>Assigned_To_Queue__c = &apos;L3 Agents&apos; &amp;&amp;  ISCHANGED( OwnerId )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>