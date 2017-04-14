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
     <xs:element ref="LongTermPlugins" />
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
    <xs:element ref="Plugin" minOccurs="0" maxOccurs="unbounded" />
   </xs:sequence>
   <xs:attribute name="lptimestamp" use="required" type="xs:dateTime" />
  </xs:complexType>
 </xs:element>
 
 <xs:element name="Plugin">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="xs:string">
     <xs:attribute name="id" type="xs:nonNegativeInteger" use="required" />
     <xs:attribute name="remotechecksum" type="feHex" use="required" />
     <xs:attribute name="localchecksum"  type="feHex" use="required" />
     <xs:attribute name="remotesize"     type="xs:nonNegativeInteger" use="required" />
     <xs:attribute name="localsize"      type="xs:nonNegativeInteger" use="required" />
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>

 <xs:element name="LongTermPlugins">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="LoadPlugin" minOccurs="0" maxOccurs="unbounded" />
   </xs:sequence>
   <xs:attribute name="lptimestamp" use="required" type="xs:dateTime" />
  </xs:complexType>
 </xs:element>

 <xs:element name="LoadPlugin">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="xs:string">
     <xs:attribute name="id" type="xs:nonNegativeInteger" use="required" />
     <xs:attribute name="status" type="xs:string" use="required" />
     <xs:attribute name="pluginError" type="xs:string" use="optional" />
     <xs:attribute name="systemError" type="xs:string" use="optional" />
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>
</xs:schema>
