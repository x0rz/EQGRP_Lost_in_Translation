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
     <xs:element ref="Ports" />
     <xs:element name="Action" type="feStringElementWithTimestamp" form="qualified"/>
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="Ports">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="Port" minOccurs='0' maxOccurs="20" />
   </xs:sequence>
   <xs:attribute name="lptimestamp" type="xs:dateTime" use="required" />
  </xs:complexType>
 </xs:element>

 <xs:element name="Port">
  <xs:complexType>
   <xs:attribute name="index" type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="lport" type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="lipAddr" type="xs:string" use="required" />
   <xs:attribute name="fport" type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="fipAddr" type="xs:string" use="required" />
  </xs:complexType>
 </xs:element>

<xs:element name="Mode">
  <xs:complexType>
   <xs:attribute name="mode" type="xs:nonNegativeInteger" use="required" />
  </xs:complexType>
</xs:element>


</xs:schema>


