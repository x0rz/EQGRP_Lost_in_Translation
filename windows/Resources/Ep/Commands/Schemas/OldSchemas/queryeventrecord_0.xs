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
     <xs:element ref="Events" />
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="Events">
  <xs:complexType>
   <xs:sequence>
    <xs:element name="Event" form="qualified" minOccurs="0" maxOccurs="unbounded">
     <xs:complexType>
      <xs:sequence>
       <xs:element name="String" form="qualified" minOccurs="0" maxOccurs="unbounded" type="xs:string"/>
       <xs:element name="Data"  form="qualified" minOccurs="0" maxOccurs="unbounded" type="xs:hexBinary"/>
      </xs:sequence>
      <xs:attribute use="required" name="timeWritten"  type="xs:dateTime"/>
      <xs:attribute use="required" name="recordNumber" type="xs:nonNegativeInteger"/>
      <xs:attribute use="required" name="eventType"    type="xs:string"/>
      <xs:attribute use="required" name="code"         type="xs:nonNegativeInteger"/>
      <xs:attribute use="required" name="severity"     type="xs:string"/>
      <xs:attribute use="required" name="type"         type="xs:string"/>
      <xs:attribute use="required" name="facility"     type="xs:string"/>
      <xs:attribute use="required" name="eventId"      type="feHex"/>
      <xs:attribute use="required" name="computer"     type="xs:string"/>
      <xs:attribute use="optional" name="sid"          type="xs:string"/>
      <xs:attribute use="required" name="source"       type="xs:string"/>
     </xs:complexType>
    </xs:element>
   </xs:sequence>
   <xs:attribute use="required" name="lptimestamp"             type="xs:dateTime" />
  </xs:complexType>
 </xs:element>

</xs:schema>
