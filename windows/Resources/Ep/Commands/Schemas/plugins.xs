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
     <xs:element ref="Plugins" />
     <xs:element ref="RemotePlugins" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="Plugins">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="Plugin" maxOccurs="unbounded" />
   </xs:sequence>
   <xs:attribute name="lptimestamp" use="required" type="xs:dateTime" />
  </xs:complexType>
 </xs:element>
 
 <xs:element name="Plugin">
  <xs:complexType>
   <xs:sequence>
    <xs:element form="qualified" name="Id"        type="xs:nonNegativeInteger" />
    <xs:element form="qualified" name="LoadCount" type="xs:nonNegativeInteger" />
    <xs:element form="qualified" name="Address"   type="feHex" minOccurs="0"/>
    <xs:element form="qualified" name="File"      type="xs:string" minOccurs="0"/>
    <xs:element ref="Version" />
   </xs:sequence>
   <xs:attribute name="type" use="required" type="xs:string" />
  </xs:complexType>
 </xs:element>
 
 <xs:element name="RemotePlugins">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="RemotePlugin" maxOccurs="unbounded" />
   </xs:sequence>
   <xs:attribute name="lptimestamp" use="required" type="xs:dateTime" />
  </xs:complexType>
 </xs:element>
 
 <xs:element name="RemotePlugin">
  <xs:complexType>
   <xs:sequence>
    <xs:element form="qualified" name="Id"        type="xs:nonNegativeInteger" />
    <xs:element form="qualified" name="AutoloadedBy"        type="xs:nonNegativeInteger" minOccurs="0"/>
    <xs:element form="qualified" name="LoadCount" type="xs:nonNegativeInteger" />
    <xs:element form="qualified" name="Address"   type="feHex" minOccurs="0"/>
    <xs:element form="qualified" name="File"      type="xs:string" minOccurs="0"/>
   </xs:sequence>
   <xs:attribute name="type" use="required" type="xs:string" />
  </xs:complexType>
 </xs:element>
 
 <xs:element name="Version">
  <xs:complexType>
   <xs:sequence>
    <xs:element form="qualified" name="Api">
     <xs:complexType>
      <xs:attribute name="major" use="required" type="xs:nonNegativeInteger" />
      <xs:attribute name="minor" use="required" type="xs:nonNegativeInteger" />
     </xs:complexType>
    </xs:element>
    <xs:element form="qualified" name="Plugin">
     <xs:complexType>
      <xs:attribute name="build" use="required" type="xs:nonNegativeInteger" />
      <xs:attribute name="major" use="required" type="xs:nonNegativeInteger" />
      <xs:attribute name="minor" use="required" type="xs:nonNegativeInteger" />
     </xs:complexType>
    </xs:element>
   </xs:sequence>
  </xs:complexType>
 </xs:element>




</xs:schema>
