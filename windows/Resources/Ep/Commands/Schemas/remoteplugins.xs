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
     <xs:element ref="Plugins" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="Plugins">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="Plugin" maxOccurs="unbounded" />
   </xs:sequence>
   <xs:attribute name="lptimestamp" use="required" type="xs:dateTime" />
  </xs:complexType>
 </xs:element>
 
 <xs:element name="Plugin">
  <xs:complexType mixed="true">
    <xs:attribute name="id"        type="xs:nonNegativeInteger" />
    <xs:attribute name="handle"    type="xs:string" />
    <xs:attribute name="major"     type="xs:nonNegativeInteger" />
    <xs:attribute name="minor"     type="xs:nonNegativeInteger" />
    <xs:attribute name="build"     type="xs:nonNegativeInteger" />
  </xs:complexType>
 </xs:element>


</xs:schema>
