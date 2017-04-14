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
     <xs:element ref="Hop" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="Hop">
  <xs:complexType>
   <xs:choice>
    <xs:element name="Timeout" form="qualified" type="feEmptyElement" />
    <xs:sequence>
     <xs:element name="Destination" form="qualified" type="xs:string" />
     <xs:element ref="Code" />
     <xs:element name="HostName" form="qualified" type="xs:string" minOccurs="0"/>
    </xs:sequence>
   </xs:choice>
   <xs:attribute name="lptimestamp" type="xs:dateTime" use="required"/>
   <xs:attribute name="hop"  type="xs:nonNegativeInteger" use="required"/>
   <xs:attribute name="ttl"  type="xs:nonNegativeInteger" use="optional"/>
   <xs:attribute name="time" type="xs:nonNegativeInteger" use="optional"/>
  </xs:complexType>
 </xs:element>

 <xs:element name="Code">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="xs:string">
     <xs:attribute name="code"     type="xs:nonNegativeInteger" use="required"/>
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>

</xs:schema>

