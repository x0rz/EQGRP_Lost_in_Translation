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
     <xs:element name="FindPlugin" type="feEmptyElementWithTimestamp" form="qualified" />
     <xs:element name="Found" type="feEmptyElementWithTimestamp" form="qualified" />
     <xs:element name="Loading" type="feEmptyElementWithTimestamp" form="qualified" />
     <xs:element ref="Loaded" />
     <xs:element ref="AlreadyLoaded" />
     <xs:element ref="Increment" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>


 <xs:element name="Loaded">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="xs:string">
     <xs:attribute name="id"          type="xs:nonNegativeInteger" use="required" />
     <xs:attribute name="address"     type="feHex"                 use="required" />
     <xs:attribute name="lptimestamp" type="xs:dateTime"           use="required" />
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>

 <xs:element name="AlreadyLoaded">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="xs:nonNegativeInteger">
     <xs:attribute name="lptimestamp" type="xs:dateTime"           use="required" />
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>

 <xs:element name="Increment">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="xs:nonNegativeInteger">
     <xs:attribute name="plugin" type="xs:nonNegativeInteger"           use="required" />
     <xs:attribute name="lptimestamp" type="xs:dateTime"           use="required" />
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>
</xs:schema>
