<?xml version="1.0"?>
<xs:schema targetNamespace="urn:ddb:expandingpulley"
           xmlns='urn:ddb:expandingpulley'           
           xmlns:xs="http://www.w3.org/2001/XMLSchema" >

 <xs:include schemaLocation="commonDefs.xs" />

 <xs:element name="Data">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="Instance"  />
    <xs:element ref="Command"/>
    <xs:element ref="Autoload" minOccurs="0" maxOccurs="unbounded" />
    <xs:choice minOccurs="0" maxOccurs="unbounded">
     <xs:element ref="Error" />
     <xs:element ref="Audit" />
     <xs:element ref="IntermediateSuccess" />
     <xs:element ref="Status" />
     <xs:element ref="TurnedOn" />
     <xs:element ref="TurnedOff" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name='OnSuccess' type='feEmptyElement'/>
 <xs:element name='OnFailure' type='feEmptyElement'/>
 <xs:element name='TurnedOn' type='feEmptyElementWithTimestamp'/>
 <xs:element name='TurnedOff' type='feEmptyElementWithTimestamp'/>

 <xs:element name='Audit'>
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base='feStringElementWithTimestamp'>
     <xs:attribute name='status' type='auditStatus' use='required'/>
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>

 <xs:element name='Status'>
  <xs:complexType>
   <xs:sequence>
    <xs:element ref='Event' minOccurs='0' maxOccurs='unbounded'/>
   </xs:sequence>
   <xs:attribute name='current' type='auditOnOff' use='required'/>
   <xs:attribute name='lptimestamp' type='xs:dateTime'/>
  </xs:complexType>
 </xs:element>

 <xs:element name='Event'>
  <xs:complexType>
    <xs:sequence>
      <xs:element ref='OnSuccess' minOccurs='0' maxOccurs='1'/>
      <xs:element ref='OnFailure' minOccurs='0' maxOccurs='1'/>
    </xs:sequence>
   <xs:attribute name='category' type='auditCategories'/>
  </xs:complexType>
 </xs:element>

 <xs:simpleType name='auditStatus'>
  <xs:restriction base='xs:string'>
    <xs:enumeration value='disabled'/>
  </xs:restriction>
 </xs:simpleType>

 <xs:simpleType name='auditOnOff'>
  <xs:restriction base='xs:string'>
    <xs:enumeration value='ON'/>
    <xs:enumeration value='OFF'/>
  </xs:restriction>
 </xs:simpleType>

 <xs:simpleType name='auditCategories'>
  <xs:restriction base='xs:string'>
    <xs:enumeration value='AuditCategorySystem'/>
    <xs:enumeration value='AuditCategoryLogon'/>
    <xs:enumeration value='AuditCategoryObjectAccess'/>
    <xs:enumeration value='AuditCategoryPrivilegeUse'/>
    <xs:enumeration value='AuditCategoryDetailedTracking'/>
    <xs:enumeration value='AuditCategoryPolicyChange'/>
    <xs:enumeration value='AuditCategoryAccountManagement'/>
    <xs:enumeration value='AuditCategoryDirectoryServiceAccess'/>
    <xs:enumeration value='AuditCategoryAccountLogon'/>
  </xs:restriction>
 </xs:simpleType>

</xs:schema>
