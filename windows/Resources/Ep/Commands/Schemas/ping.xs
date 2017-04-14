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
     <xs:element ref="PingResponses" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="PingResponses">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="Response" maxOccurs="unbounded" />
   </xs:sequence>
   <xs:attribute name="lptimestamp" type="xs:dateTime" use="required" />
  </xs:complexType>
 </xs:element>

 <xs:element name="Response">
  <xs:complexType>
   <xs:sequence>
    <xs:element name="Data" type="xs:string" form="qualified" />
    <xs:element ref="Ip"/>
   </xs:sequence>
   <xs:attribute name="elapsed" type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="length" type="xs:nonNegativeInteger" use="required" />
  </xs:complexType>
 </xs:element>

 <xs:element name="Ip">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="Icmp"/>
   </xs:sequence>
   <xs:attribute name="version"   	type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="headerLength"    type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="source"		type="xs:string" use="required" />
   <xs:attribute name="destination"	type="xs:string" use="required" />
   <xs:attribute name="ttl"		type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="protocol"	type="xs:nonNegativeInteger" use="required" />
  </xs:complexType>
 </xs:element>

 <xs:element name="Icmp">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base='feEmptyElement'>
     <xs:attribute name='type' type='xs:nonNegativeInteger' use='required'/>
     <xs:attribute name='code' type='xs:nonNegativeInteger' use='required'/>
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>

</xs:schema>
