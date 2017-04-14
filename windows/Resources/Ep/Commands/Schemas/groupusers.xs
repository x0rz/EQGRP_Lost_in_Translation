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
    <xs:choice minOccurs="0" maxOccurs="unbounded">
     <xs:element ref="User" />
     <xs:element ref="Autoload" />
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
   <xs:attribute name="user"                     type="xs:string"             use="required" />
   <xs:attribute name="attributes"               type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="lptimestamp"              type="xs:dateTime"           use="required" />
  </xs:complexType>
 </xs:element>

</xs:schema>
