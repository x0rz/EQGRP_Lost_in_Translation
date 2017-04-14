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
     <xs:element ref="Child" />
     <xs:element ref="Error" />
     <xs:element ref="Stop" />
     <xs:element name="Stopped" form="qualified" type="feEmptyElementWithTimestamp" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>
 
 <xs:element name="Child">
  <xs:complexType>
   <xs:attribute name="request"      type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="childRequest" type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="lptimestamp"  type="xs:dateTime" use="required" />
  </xs:complexType>
 </xs:element>
 
 <xs:element name="Stop">
  <xs:complexType>
   <xs:attribute name="request" type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="type"    type="xs:string"             use="required" />
   <xs:attribute name="lptimestamp"  type="xs:dateTime" use="required" />
  </xs:complexType>
 </xs:element>


</xs:schema>
