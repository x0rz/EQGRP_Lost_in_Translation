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
     <xs:element ref="Arp" />
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="Arp">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="Entry" maxOccurs="unbounded" />
   </xs:sequence>
   <xs:attribute name="lptimestamp" type="xs:dateTime" />
  </xs:complexType>
 </xs:element>

 <xs:element name="Entry">
  <xs:complexType>
   <xs:sequence>
    <xs:element form="qualified" type="xs:string" name="InterfaceIp" />
    <xs:element form="qualified" type="xs:string" name="Ip" />
    <xs:element form="qualified" type="xs:string" name="PhysicalAddress" />
    <xs:element ref="Type" />
   </xs:sequence>
   <xs:attribute name="index" type="feHex" />
  </xs:complexType>
 </xs:element>

 <xs:element name="Type">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="xs:string">
     <xs:attribute name="code"      type="xs:nonNegativeInteger" />
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>

</xs:schema>
