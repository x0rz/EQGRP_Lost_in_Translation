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
     <xs:element ref="Commands" />
     <xs:element ref="Total" />
     <xs:element ref="Channels" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>
 
 <xs:element name="Commands">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="Cmd" minOccurs="0" maxOccurs="unbounded" />
   </xs:sequence>
   <xs:attribute name="lptimestamp" use="required" type="xs:dateTime" />
  </xs:complexType>
 </xs:element>
 
 <xs:element name="Cmd">
  <xs:complexType>
   <xs:sequence>
    <xs:element form="qualified" name="Asynchronous" type="feEmptyElement" minOccurs="0"/>
    <xs:element form="qualified" name="Released" type="feEmptyElement" minOccurs="0"/>
    <xs:element form="qualified" name="Sent"         type="transferType" />
    <xs:element form="qualified" name="Received"     type="transferType" />
    <xs:element form="qualified" name="CommandLine"  type="xs:string" />
   </xs:sequence>
   <xs:attribute name="index" type="xs:nonNegativeInteger" use="required" />
   <xs:attribute name="request" type="xs:nonNegativeInteger" use="required" />
  </xs:complexType>
 </xs:element>

 <xs:element name="Total">
  <xs:complexType>
   <xs:sequence>
    <xs:element form="qualified" name="Received"     type="xs:nonNegativeInteger" />
    <xs:element form="qualified" name="Sent"         type="xs:nonNegativeInteger" />
   </xs:sequence>
   <xs:attribute name="lptimestamp" use="required" type="xs:dateTime" />
  </xs:complexType>
 </xs:element>

 <xs:element name="Channels">
  <xs:complexType>
   <xs:sequence>
    <xs:element name="Channel" form="qualified" maxOccurs="unbounded" minOccurs="0">
     <xs:complexType>
      <xs:sequence>
       <xs:element form="qualified" name="Released"     type="feEmptyElement" minOccurs="0"/>
       <xs:element form="qualified" name="Local"        type="feEmptyElement" minOccurs="0"/>
       <xs:element form="qualified" name="Sent"         type="transferType" />
       <xs:element form="qualified" name="Received"     type="transferType" />
      </xs:sequence>     
      <xs:attribute name="id" type="xs:nonNegativeInteger" use="required" />
      <xs:attribute name="request" type="xs:nonNegativeInteger" use="required" />
      <xs:attribute name="commandRequest" type="xs:nonNegativeInteger" use="required" />
     </xs:complexType>
    </xs:element>
   </xs:sequence>
   <xs:attribute name="lptimestamp" use="required" type="xs:dateTime" />
  </xs:complexType>
 </xs:element>
 
 <xs:complexType name="transferType">
  <xs:attribute name="total" use="required" type="xs:nonNegativeInteger" />
  <xs:attribute name="ratio" use="required" type="xs:nonNegativeInteger" />
 </xs:complexType>

</xs:schema>

