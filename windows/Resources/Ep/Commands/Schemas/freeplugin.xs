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
     <xs:element ref ="Error" />
     <xs:element name="Freed"     type="feEmptyElementWithTimestamp" form='qualified' />
     <xs:element name="FreeLocal" type="feEmptyElementWithTimestamp" form='qualified' />
     <xs:element ref ="LoadCount"/>
     <xs:element ref ="Plugin"/>
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>
 
 <xs:element name="Plugin">
  <xs:complexType>
   <xs:attribute name="filename"    type="xs:string"             use="optional" />
   <xs:attribute name="type"        type="xs:string"             use="required" />
   <xs:attribute name="id"          type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="lptimestamp" type="xs:dateTime"           use="required" />
  </xs:complexType>
 </xs:element>


 <xs:element name="LoadCount">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="xs:nonNegativeInteger">
     <xs:attribute name="lptimestamp" type="xs:dateTime" />
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>


</xs:schema>
