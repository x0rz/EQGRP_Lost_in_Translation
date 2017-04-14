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
     <xs:element ref="Autoload" minOccurs="0" maxOccurs="unbounded" />
     <xs:element ref="LocalListen" />
     <xs:element ref="IntermediateSuccess" />
     <xs:element ref="Info" />
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="LocalListen">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="feEmptyElementWithTimestamp">
     <xs:attribute name="address"  type="xs:string" />
     <xs:attribute name="port"     type="xs:nonNegativeInteger" />
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>

 <xs:element name="Info" type="feStringElementWithTimestamp"/>

</xs:schema>
