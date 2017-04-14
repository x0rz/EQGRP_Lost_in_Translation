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
     <xs:element ref="Prefixes" />
     <xs:element ref="BuiltIn" />
     <xs:element ref="Plugins" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>
 
 <xs:element name="Prefixes">
  <xs:complexType>
   <xs:sequence>
    <xs:element form="qualified" name="Prefix" type="xs:string" minOccurs="0" maxOccurs="unbounded"/>
   </xs:sequence>
   <xs:attribute name="lptimestamp" type='xs:dateTime' use="required" />
  </xs:complexType>
 </xs:element>

 <xs:element name="BuiltIn">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="Cmd" minOccurs="0" maxOccurs="unbounded"/>
   </xs:sequence>
   <xs:attribute name="lptimestamp" type='xs:dateTime' use="required" />
  </xs:complexType>
 </xs:element>

 <xs:element name="Plugins">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="Cmd" minOccurs="0" maxOccurs="unbounded"/>
   </xs:sequence>
   <xs:attribute name="lptimestamp" type='xs:dateTime' use="required" />
  </xs:complexType>
 </xs:element>
 
 <xs:element name="Cmd">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="xs:string">
     <xs:attribute name="loaded"     type="xs:string" />
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>
 

</xs:schema>
