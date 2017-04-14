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
     <xs:element ref="FilePerms" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="FilePerms">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="Acl" minOccurs="0" maxOccurs="unbounded" />
   </xs:sequence>
   <xs:attribute name="accountName" type="xs:string" use='required'/>
   <xs:attribute name="domainName" type="xs:string" use='required'/>
   <xs:attribute name="file" type="xs:string" use='required'/>
   <xs:attribute name="groupDomainName" type="xs:string" use='required'/>
   <xs:attribute name="groupName" type="xs:string" use='required'/>
   <xs:attribute name="lptimestamp" type="xs:dateTime" use='required'/>
  </xs:complexType>
 </xs:element>

 <xs:element name="Acl">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="Ace" minOccurs="0" maxOccurs="unbounded" />
   </xs:sequence>
   <xs:attribute name="type" type="xs:nonNegativeInteger" use='required'/>
  </xs:complexType>
 </xs:element>

 <xs:element name="Ace">
  <xs:complexType>
   <xs:sequence>
     <xs:element ref="Flags"/>
     <xs:element ref="Mask"/>
   </xs:sequence>
   <xs:attribute name="type" type="xs:nonNegativeInteger" use='required'/>
   <xs:attribute name="user" type="xs:string" use='required'/>
   <xs:attribute name="domain" type="xs:string" use='required'/>   
  </xs:complexType>
 </xs:element>

 <xs:element name="Flags">
  <xs:complexType>
   <xs:sequence>
	<xs:element ref="FailedAccessAce" minOccurs="0"/>
	<xs:element ref="SuccessfulAccessAce" minOccurs="0"/>
	<xs:element ref="ContainerInheritAce" minOccurs="0"/>
	<xs:element ref="InheritOnlyAce" minOccurs="0"/>
	<xs:element ref="InheritedAce" minOccurs="0"/>
	<xs:element ref="NoPropogateInheritAce" minOccurs="0"/>
	<xs:element ref="ObjectInheritAce" minOccurs="0"/>
    </xs:sequence>
   <xs:attribute name="value" type="feHex" use='required'/>
   <xs:attribute name="unknown" type="feHex" use='optional'/>
  </xs:complexType>
 </xs:element>

 <xs:element name="FailedAccessAce" type="feEmptyElement"/>
 <xs:element name="SuccessfulAccessAce" type="feEmptyElement"/>
 <xs:element name="ContainerInheritAce" type="feEmptyElement"/>
 <xs:element name="InheritOnlyAce" type="feEmptyElement"/>
 <xs:element name="InheritedAce" type="feEmptyElement"/>
 <xs:element name="NoPropogateInheritAce" type="feEmptyElement"/>
 <xs:element name="ObjectInheritAce" type="feEmptyElement"/>

 <xs:element name="Mask">
  <xs:complexType>
   <xs:sequence>
	<xs:element ref="FullControlMask" minOccurs="0"/>
	<xs:element ref="ReadWriteMask" minOccurs="0"/>
	<xs:element ref="GenericWriteMask" minOccurs="0"/>
	<xs:element ref="GenericReadMask" minOccurs="0"/>
	<xs:element ref="Delete" minOccurs="0"/>
	<xs:element ref="WriteDac" minOccurs="0"/>
	<xs:element ref="WriteOwner" minOccurs="0"/>
	<xs:element ref="ExecuteMask" minOccurs="0"/>
	<xs:element ref="FileExecute" minOccurs="0"/>
	<xs:element ref="FileReadData" minOccurs="0"/>
	<xs:element ref="FileWriteData" minOccurs="0"/>
	<xs:element ref="FileWriteEA" minOccurs="0"/>
	<xs:element ref="FileAppendData" minOccurs="0"/>
	<xs:element ref="FileDeleteChild" minOccurs="0"/>
	<xs:element ref="FileReadAttributes" minOccurs="0"/>
	<xs:element ref="FileWriteAttributes" minOccurs="0"/>
	<xs:element ref="ReadControl" minOccurs="0"/>
	<xs:element ref="Synchronize" minOccurs="0"/>
	<xs:element ref="FileReadEA" minOccurs="0"/>
    </xs:sequence>
   <xs:attribute name="value" type="feHex" use='required'/>
   <xs:attribute name="unknown" type="feHex" use='optional'/>
  </xs:complexType>
 </xs:element>

 <xs:element name="FullControlMask" type="feEmptyElement"/>
 <xs:element name="ReadWriteMask" type="feEmptyElement"/>
 <xs:element name="GenericWriteMask" type="feEmptyElement"/>
 <xs:element name="GenericReadMask" type="feEmptyElement"/>
 <xs:element name="Delete" type="feEmptyElement"/>
 <xs:element name="WriteDac" type="feEmptyElement"/>
 <xs:element name="WriteOwner" type="feEmptyElement"/>
 <xs:element name="ExecuteMask" type="feEmptyElement"/>
 <xs:element name="FileExecute" type="feEmptyElement"/>
 <xs:element name="FileReadData" type="feEmptyElement"/>
 <xs:element name="FileWriteData" type="feEmptyElement"/>
 <xs:element name="FileWriteEA" type="feEmptyElement"/>
 <xs:element name="FileAppendData" type="feEmptyElement"/>
 <xs:element name="FileDeleteChild" type="feEmptyElement"/>
 <xs:element name="FileReadAttributes" type="feEmptyElement"/>
 <xs:element name="FileWriteAttributes" type="feEmptyElement"/>
 <xs:element name="ReadControl" type="feEmptyElement"/>
 <xs:element name="Synchronize" type="feEmptyElement"/>
 <xs:element name="FileReadEA" type="feEmptyElement"/>

</xs:schema>
