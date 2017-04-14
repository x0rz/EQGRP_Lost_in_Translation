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
     <xs:element ref="Interfaces" />
     <xs:element ref="Routes" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="Interfaces">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="Interface" maxOccurs="unbounded" />
   </xs:sequence>
   <xs:attribute name="lptimestamp" type="xs:dateTime" />
  </xs:complexType>
 </xs:element>

 <xs:element name="Routes">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="Route" maxOccurs="unbounded" />
   </xs:sequence>
   <xs:attribute name="lptimestamp" type="xs:dateTime" />
  </xs:complexType>
 </xs:element>

 <xs:element name="Interface">
  <xs:complexType>
   <xs:sequence>
    <xs:element name="Description" type="xs:string" form="qualified" />
    <xs:element name="PhysAddr" type="xs:string" form="qualified" minOccurs="0"/>
   </xs:sequence>
   <xs:attribute name="index" type="xs:string" use="required"/>
   <xs:attribute name="ip" type="xs:string" use="optional"/>
  </xs:complexType>
 </xs:element>

 <xs:element name="Route">
  <xs:complexType>
   <xs:attribute name="destination" type="xs:string" use="required"/>
   <xs:attribute name="mask" type="xs:string" use="required"/>
   <xs:attribute name="gateway" type="xs:string" use="required"/>
   <xs:attribute name="interfaceIndex" type="feHex" use="required"/>
   <xs:attribute name="ip" type="xs:string" use="optional"/>
   <xs:attribute name="metric1" type="xs:integer" use="required"/>
   <xs:attribute name="metric2" type="xs:integer" use="required"/>
   <xs:attribute name="metric3" type="xs:integer" use="required"/>
   <xs:attribute name="metric4" type="xs:integer" use="required"/>
  </xs:complexType>
 </xs:element>

</xs:schema>
