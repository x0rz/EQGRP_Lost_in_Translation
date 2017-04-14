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
     <xs:element ref="LocalSocket" />
     <xs:element ref="NewConnection" />
     <xs:element ref="NewPacket" />
     <xs:element ref="PacketData" />
     <xs:element ref="PacketSent" />
     <xs:element ref="ConnectionClosed" />
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="LocalSocket">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="feEmptyElementWithTimestamp">
     <xs:attribute name="address"  type="xs:string" />
     <xs:attribute name="port"     type="xs:nonNegativeInteger" />
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>

 <xs:element name="NewConnection">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="feEmptyElementWithTimestamp">
     <xs:attribute name="address"  type="xs:string" />
     <xs:attribute name="port"     type="xs:nonNegativeInteger" />
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>

 <xs:element name="NewPacket">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="feEmptyElementWithTimestamp">
     <xs:attribute name="size"     type="xs:nonNegativeInteger" />
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>

 <xs:element name="PacketData">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="xs:string">
     <xs:attribute name="size" type="xs:nonNegativeInteger" />
     <xs:attribute name="lptimestamp" type="xs:dateTime" />
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>

 <xs:element name="PacketSent" type="feEmptyElementWithTimestamp"/>
 <xs:element name="ConnectionClosed" type="feEmptyElementWithTimestamp"/>

</xs:schema>
