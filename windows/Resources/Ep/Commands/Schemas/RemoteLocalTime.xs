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
     <xs:element ref="RemoteLocalTime" />
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="RemoteLocalTime">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref="Time" />
    <xs:element ref="TimeZone" />
    <xs:element ref="DaylightSavings" minOccurs="0" />
   </xs:sequence>
   <xs:attribute name="lptimestamp"     type="xs:dateTime" use="required"/>
  </xs:complexType>
 </xs:element>

 <xs:element name="Time">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base="xs:dateTime">
     <xs:attribute name="locale" type="Locale" use="required"/> 
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>

 <xs:element name="TimeZone">
  <xs:complexType>
   <xs:sequence>
	<xs:element name="Bias" form="qualified" type="xs:string"/>
	<xs:element name="Name" form="qualified" type="xs:string"/>
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="DaylightSavings">
  <xs:complexType>
   <xs:sequence>
	<xs:element name="Bias" form="qualified" type="xs:string"/>
	<xs:element name="Name" form="qualified" type="xs:string"/>
	<xs:element name="Start" form="qualified" type="dsDate"/>
	<xs:element name="End" form="qualified" type="dsDate"/>
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:complexType name="dsDate">
    <xs:choice minOccurs="3" maxOccurs="unbounded">
	<xs:element name="Month" form="qualified" type="dsValue"/>
	<xs:element name="Day" form="qualified" type="dsValue"/>
	<xs:element name="Week" form="qualified" type="dsValue"/>
    </xs:choice>
 </xs:complexType>

 <xs:complexType name="dsValue">
   <xs:simpleContent>
    <xs:extension base="xs:string">
        <xs:attribute name="value" type="xs:nonNegativeInteger" use="required"/>
    </xs:extension>
   </xs:simpleContent>
 </xs:complexType>

 <xs:simpleType name='Locale'>
  <xs:restriction base='xs:string'>
    <xs:enumeration value="remotelocal"/>
  </xs:restriction>
 </xs:simpleType>
</xs:schema>
