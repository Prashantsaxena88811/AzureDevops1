<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Mulesoft_Retry_Failure_Nalco</fullName>
        <ccEmails>bhkn@deloitte.com</ccEmails>
        <description>Mulesoft Retry Failure Nalco</description>
        <protected>false</protected>
        <recipients>
            <field>Support_Email_Nalco__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>donotreply-portal@ecolab.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/EC_Order_Submit_Failure_Nalco</template>
    </alerts>
    <alerts>
        <fullName>Nalco_OrderItem_Submit</fullName>
        <description>Nalco OrderItem Submit</description>
        <protected>false</protected>
        <recipients>
            <field>EC_CSR_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/EC_OrderItem_Submit_Email</template>
    </alerts>
</Workflow>
