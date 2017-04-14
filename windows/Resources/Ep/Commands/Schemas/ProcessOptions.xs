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
    <xs:element ref="ExecuteOptions" minOccurs="0"/>
    <xs:element ref="Error" minOccurs="0" maxOccurs="unbounded"/>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="ExecuteOptions">
  <xs:complexType>
    <xs:sequence>
	<xs:element name="ExecutionDisabled" form="qualified" type="feEmptyElement" minOccurs="0" />
	<xs:element name="ExecutionEnabled" form="qualified" type="feEmptyElement" minOccurs="0" />
	<xs:element name="DisableThunkEmulation" form="qualified" type="feEmptyElement" minOccurs="0" />
	<xs:element name="Permanent" form="qualified" type="feEmptyElement" minOccurs="0" />
	<xs:element name="ExecuteDispatchEnabled" form="qualified" type="feEmptyElement" minOccurs="0" />
	<xs:element name="ImageDispatchEnabled" form="qualified" type="feEmptyElement" minOccurs="0" />
    </xs:sequence>
    <xs:attribute name="value"       type="feHex" use="required" />
    <xs:attribute name="lptimestamp" type="xs:dateTime" use="required" />
  </xs:complexType>
 </xs:element>

</xs:schema>
