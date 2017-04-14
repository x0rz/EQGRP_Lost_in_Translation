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
     <xs:element ref="Entry" />
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="Entry">
  <xs:complexType>
    <xs:sequence>
      <xs:element name="Category" type="xs:string" form="qualified"/>
      <xs:element name="Name" type="xs:string" form="qualified"/>
      <xs:element name="DistinguishedName" type="xs:string" form="qualified"/>
    </xs:sequence>
    <xs:attribute name="lptimestamp" type="xs:dateTime" use="required"/>
  </xs:complexType>
 </xs:element>

</xs:schema>
