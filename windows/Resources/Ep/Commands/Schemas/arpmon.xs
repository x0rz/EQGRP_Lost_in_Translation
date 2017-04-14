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
    <xs:element ref="ArpMon" minOccurs="1"/>
    <xs:element ref="Autoload" minOccurs="0" maxOccurs="1" />
    <xs:choice minOccurs="0" maxOccurs="unbounded">
     <xs:element ref="ArpMon" minOccurs="1" maxOccurs="unbounded"/>
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>


<xs:element name="ArpMon">
  <xs:complexType>
    <xs:sequence>
      <xs:element ref="Header" minOccurs="0" maxOccurs="1"/> 
      <xs:element ref="Entry" minOccurs="0" maxOccurs="1"/>
    </xs:sequence>
    <xs:attribute name="lptimestamp" type="xs:dateTime" />
  </xs:complexType>
</xs:element>

<xs:element name="Header"/>

<xs:element name="Entry">
  <xs:complexType>
    <xs:sequence>
      <xs:element form="qualified" type="xs:string" name="Ip" />
      <xs:element form="qualified" type="xs:string" name="PhysicalAddress" />
      <xs:element form="qualified" type="xs:string" name="Type" />
      <xs:element form="qualified" type="xs:string" name="Interface" />
    </xs:sequence>
  </xs:complexType>
</xs:element>

</xs:schema>

