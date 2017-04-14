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
     <xs:element ref="LSA_Secret" />
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="LSA_Secret">
  <xs:complexType>
   <xs:sequence>
    <xs:element name="Secret"            	type="xs:string"  form="qualified"/>
    <xs:element name="LSA_Data"            	type="xs:string"  minOccurs="0" form="qualified"/>
   </xs:sequence>
   <xs:attribute name="lptimestamp" 		type="xs:dateTime" use="required"/>
  </xs:complexType>
 </xs:element>


</xs:schema>





