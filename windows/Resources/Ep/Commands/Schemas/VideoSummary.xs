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
     <xs:element ref="VideoSummary" />
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
    <xs:element ref="Error" minOccurs="0" maxOccurs="unbounded"/>
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="VideoSummary">
  <xs:complexType>
    <xs:simpleContent>
      <xs:extension base='xs:hexBinary'>
   		<xs:attribute name="jpegFileName" 	type="xs:string"/>
   		<xs:attribute name="jpegSize" 	type="xs:nonNegativeInteger"/>
	        <xs:attribute name='lptimestamp' type='xs:dateTime' use='required'/>
      </xs:extension>
    </xs:simpleContent>
  </xs:complexType>
 </xs:element>

</xs:schema>





