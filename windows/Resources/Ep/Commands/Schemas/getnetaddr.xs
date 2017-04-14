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
     <xs:element form="qualified" type="AddyInfo" name="Local" />
     <xs:element form="qualified" type="AddyInfo" name="LocalPeer" />
     <xs:element form="qualified" type="AddyInfo" name="Remote" />
     <xs:element form="qualified" type="AddyInfo" name="RemotePeer" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>
 
 <xs:complexType name="AddyInfo">
  <xs:sequence>
   <xs:element name="Address" form="qualified" type="xs:string" />
   <xs:element name="Port" form="qualified" type="xs:nonNegativeInteger" />
  </xs:sequence>
  <xs:attribute name="lptimestamp" use="required" type="xs:dateTime" />
 </xs:complexType>

</xs:schema>
