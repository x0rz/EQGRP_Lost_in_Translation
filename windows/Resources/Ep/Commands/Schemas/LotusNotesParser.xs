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
     <xs:element ref="LotusNotesParser" />
     <xs:element ref="Error" />
    </xs:choice>
    <xs:choice>
     <xs:element ref="Success" />
     <xs:element ref="Failure" />
    </xs:choice> 
   </xs:sequence>
  </xs:complexType>
 </xs:element>

 <xs:element name="LotusNotesParser">
  <xs:complexType>
    <xs:sequence>
      <xs:element ref='Email' minOccurs='0' maxOccurs='unbounded'/>
    </xs:sequence>
      <xs:attribute name="msgsProcessed" type="xs:nonNegativeInteger"/>
      <xs:attribute name="lptimestamp"  type="xs:dateTime"/>
  </xs:complexType>
 </xs:element>

 <xs:element name="Email">
  <xs:complexType>
    <xs:sequence>
          <xs:element ref="MsgID"/>
          <xs:element name="To" 		type="feStringElementWithError" form="qualified"/>
          <xs:element name="From" 		type="feStringElementWithError" form="qualified"/>
          <xs:element name="CC" 		type="feStringElementWithError" form="qualified"/>
          <xs:element name="Bcc" 		type="feStringElementWithError" form="qualified"/>
          <xs:element name="Subject" 		type="feStringElementWithError" form="qualified"/>
          <xs:element name="ComposedDate" 	type="feStringElementWithError" form="qualified"/>
          <xs:element name="PostedDate" 	type="feStringElementWithError" form="qualified"/>
          <xs:element name="DeliveredDate" 	type="feStringElementWithError" form="qualified"/>
          <xs:element name="Body" 		type="feStringElementWithError" form="qualified" minOccurs='0'/>
	  <xs:element ref='Attachment' minOccurs='0' maxOccurs='unbounded'/>
    </xs:sequence>
    <xs:attribute name="bodyReq" type="xs:boolean"/>
    <xs:attribute name="attVal"	type="xs:boolean"/>
    <xs:attribute name="numAtt" type="xs:nonNegativeInteger"/>
  </xs:complexType>
 </xs:element>

 <xs:element name="MsgID">
  <xs:complexType>
     <xs:simpleContent>
       <xs:extension base='xs:nonNegativeInteger'>
          <xs:attribute name='error' type='feHex' use='required'/>
       </xs:extension>
     </xs:simpleContent>
  </xs:complexType>
 </xs:element>

 <xs:element name="Attachment">
  <xs:complexType>
    <xs:simpleContent>
      <xs:extension base='xs:hexBinary'>
   		<xs:attribute name="attName" 	type="xs:string"/>
   		<xs:attribute name="attSize" 	type="xs:nonNegativeInteger"/>
		<xs:attribute name='error' type='feHex'/>
      </xs:extension>
    </xs:simpleContent>
  </xs:complexType>
 </xs:element>

 <xs:complexType name='feStringElementWithError'>
   <xs:simpleContent>
    <xs:extension base='xs:string'>
     <xs:attribute name='error' type='feHex' use='required'/>
    </xs:extension>
   </xs:simpleContent>
 </xs:complexType>

</xs:schema>






