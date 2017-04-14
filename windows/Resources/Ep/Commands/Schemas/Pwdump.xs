<?xml version="1.0"?>
<xs:schema targetNamespace="urn:ddb:expandingpulley" xmlns='urn:ddb:expandingpulley' xmlns:xs="http://www.w3.org/2001/XMLSchema" >

 <xs:include schemaLocation="commonDefs.xs" />

 <xs:element name="Data">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="Instance"  />
    <xs:element ref="Command"/>
    <xs:element ref="Autoload" minOccurs="0" maxOccurs="unbounded" />
    <xs:choice minOccurs="0" maxOccurs="unbounded">
     <xs:element ref="User" />
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="User">
  <xs:complexType>
   <xs:sequence>
    <xs:element name="LanmanHash"            	type="xs:string"  form="qualified"/>
    <xs:element name="NtHash"            	type="xs:string"  form="qualified"/>
    <xs:element ref="Flags"/>
    <xs:element name="Username"          	type="xs:string"  form="qualified"/>

   </xs:sequence>
   <xs:attribute name="rid"              	type="xs:nonNegativeInteger" use="required"/>
   <xs:attribute name="lptimestamp" 		type="xs:dateTime" use="required"/>
  </xs:complexType>
 </xs:element>


 <xs:element name="Flags">
  <xs:complexType>
   <xs:sequence>
    <xs:element form="qualified" minOccurs="0" type="feEmptyElement" name="IsNtPasswordPresent" />
    <xs:element form="qualified" minOccurs="0" type="feEmptyElement" name="IsLmPasswordPresent" />
    <xs:element form="qualified" minOccurs="0" type="feEmptyElement" name="IsPasswordExpired" />
    <xs:element form="qualified" minOccurs="0" type="feEmptyElement" name="IsHashException" />
    <xs:element form="qualified" minOccurs="0" type="feEmptyElement" name="IsRegNTcmp" />
    <xs:element form="qualified" minOccurs="0" type="feEmptyElement" name="IsRegLanmancmp" />
   </xs:sequence>
  </xs:complexType>  
 </xs:element>

</xs:schema>


