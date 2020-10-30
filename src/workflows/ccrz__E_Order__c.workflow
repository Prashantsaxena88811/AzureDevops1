<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EC_Order_Submit_Failure_Nalco</fullName>
        <description>Order Submit Failure Nalco</description>
        <protected>false</protected>
        <recipients>
            <field>EC_Support_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/EC_Order_Submit_Failure_Nalco</template>
    </alerts>
</Workflow>
