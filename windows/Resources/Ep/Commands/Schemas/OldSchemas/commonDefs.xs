<?xml version="1.0"?>
<xs:schema targetNamespace="urn:ddb:expandingpulley"  
	xmlns="urn:ddb:expandingpulley"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" >

 <!-- Elements -->
 <xs:element  name="Instance">
  <xs:complexType>
   <xs:attribute name='id' type='feGUID' use='required'/>
   <xs:attribute name='lptimestamp' type='xs:dateTime' use='required'/>
  </xs:complexType>
 </xs:element>

 <xs:element name="Autoload">
  <xs:complexType>
   <xs:attribute name='usefile' type='xs:boolean' use='required'/>
   <xs:attribute name='plugin' type='xs:nonNegativeInteger' use='required'/>
   <xs:attribute name='type' type='feLocation' use='required'/>
   <xs:attribute name='lptimestamp' type='xs:dateTime' use='optional'/>
  </xs:complexType>
 </xs:element>

 <xs:element name="Command">
  <xs:complexType>
   <xs:sequence>
    <xs:element ref='Prefix' minOccurs='0' maxOccurs='unbounded'/>
    <xs:element ref='Argument' minOccurs='0' maxOccurs='unbounded'/>
   </xs:sequence>
   <xs:attribute name='request' type='xs:nonNegativeInteger' use='required'/>
   <xs:attribute name='name' type='xs:string' use='required'/>
   <xs:attribute name='lptimestamp' type='xs:dateTime'/>
  </xs:complexType>
 </xs:element>

 <xs:element name="Error">
  <xs:complexType>
   <xs:simpleContent>
    <xs:extension base='xs:string'>
     <xs:attribute name='type' type='feErrorType'/>
     <xs:attribute name='value' type='xs:nonNegativeInteger'/>
     <xs:attribute name='lptimestamp' type='xs:dateTime'/>
    </xs:extension>
   </xs:simpleContent>
  </xs:complexType>
 </xs:element>

 <xs:element name="IntermediateSuccess">
   <xs:complexType>
     <xs:simpleContent>
       <xs:extension base='feEmptyElementWithTimestamp'>
         <xs:attribute name='request' type='xs:nonNegativeInteger' use='required'/>
       </xs:extension>
     </xs:simpleContent>
   </xs:complexType>
 </xs:element>

 <xs:element name='Prefix' type='xs:string'/>
 <xs:element name='Argument' type='xs:string'/>
 <xs:element name="Success" type="feEmptyElementWithTimestamp"/>
 <xs:element name="Failure" type="feEmptyElementWithTimestamp"/>

 <!-- Useful types -->
 <xs:simpleType name='feHex'>
  <xs:restriction base='xs:string'>
    <xs:minLength value='3'/>
    <xs:maxLength value='10'/>
    <xs:pattern value='0x[0-9a-fA-F]*'/>
  </xs:restriction>
 </xs:simpleType>

 <xs:simpleType name='feLocation'>
  <xs:restriction base='xs:string'>
    <xs:pattern value='local'/>
    <xs:pattern value='remote'/>
  </xs:restriction>
 </xs:simpleType>

 <xs:simpleType name='feErrorType'>
  <xs:restriction base='xs:string'>
    <xs:pattern value='plugin'/>
    <xs:pattern value='system'/>
  </xs:restriction>
 </xs:simpleType>

 <xs:simpleType name='feGUID'>
  <xs:restriction base='xs:string'>
    <xs:length value='36'/>
    <xs:pattern value='[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'/>
  </xs:restriction>
 </xs:simpleType>

 <xs:simpleType name='feEmptyElement'>
  <xs:restriction base='xs:string'>
    <xs:enumeration value=""/>
  </xs:restriction>
 </xs:simpleType>

 <xs:complexType name='feEmptyElementWithTimestamp'>
   <xs:simpleContent>
    <xs:extension base='feEmptyElement'>
     <xs:attribute name='lptimestamp' type='xs:dateTime' use='required'/>
    </xs:extension>
   </xs:simpleContent>
 </xs:complexType>

 <xs:complexType name='feStringElementWithTimestamp'>
   <xs:simpleContent>
    <xs:extension base='xs:string'>
     <xs:attribute name='lptimestamp' type='xs:dateTime' use='required'/>
    </xs:extension>
   </xs:simpleContent>
 </xs:complexType>

</xs:schema>
